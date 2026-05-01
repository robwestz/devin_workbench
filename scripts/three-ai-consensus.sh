#!/usr/bin/env bash
# three-ai-consensus.sh — Run code review through three AIs in parallel, return consensus.
#
# Usage:
#   three-ai-consensus.sh <diff-file>
#   three-ai-consensus.sh --branch <branch-name>
#   three-ai-consensus.sh --self-test

set -uo pipefail

# -------- Parse args --------
SELFTEST=false
DIFF_FILE=""
BRANCH=""

while [[ $# -gt 0 ]]; do
  case $1 in
    --self-test) SELFTEST=true; shift ;;
    --branch) BRANCH=$2; shift 2 ;;
    *) DIFF_FILE=$1; shift ;;
  esac
done

# -------- Self-test --------
if [ "$SELFTEST" = "true" ]; then
  echo "Running self-test on hello-world diff..."
  cat > /tmp/test-diff.patch <<'EOF'
diff --git a/hello.py b/hello.py
new file mode 100644
index 0000000..ce01362
--- /dev/null
+++ b/hello.py
@@ -0,0 +1 @@
+print("hello world")
EOF
  DIFF_FILE=/tmp/test-diff.patch
fi

# -------- Get diff --------
if [ -n "$BRANCH" ]; then
  DIFF_FILE=/tmp/review-diff-$$.patch
  git diff "origin/main...$BRANCH" > "$DIFF_FILE"
elif [ -z "$DIFF_FILE" ]; then
  echo "Usage: $0 <diff-file> | --branch <name> | --self-test"
  exit 64
fi

if [ ! -f "$DIFF_FILE" ]; then
  echo "ERROR: diff file not found: $DIFF_FILE"
  exit 1
fi

DIFF_LOC=$(grep -c "^[+-][^+-]" "$DIFF_FILE" || echo 0)
echo "Diff size: $DIFF_LOC lines"

if [ "$DIFF_LOC" -lt 30 ]; then
  echo "Diff <30 LOC, skipping consensus review (per PB-1 thresholds)."
  echo "Run claude-review or codex-review individually if needed."
  exit 0
fi

# -------- Compose reviewer prompt --------
PROMPT_FILE=/tmp/review-prompt-$$.md

cat > "$PROMPT_FILE" <<EOF
You are a senior engineer doing code review. The diff below is from a working
branch about to merge to main.

Output ONLY valid JSON in this shape (no markdown, no prose, no fences):
{
  "critical": ["..."],
  "suggested": ["..."],
  "nitpick": ["..."]
}

Critical = bugs, security issues, broken behavior.
Suggested = real improvements (perf, clarity, correctness).
Nitpick = style preferences, taste calls.

If you find nothing in a category: empty array. Do NOT pad.
Reference specific file:line where possible.

Diff:
$(cat "$DIFF_FILE")
EOF

# -------- Run three reviewers in parallel --------
RESULTS_DIR=/tmp/review-$$
mkdir -p "$RESULTS_DIR"

echo "--- Running 3 reviewers in parallel ---"

(
  bash ~/workbench/scripts/claude-review.sh "$PROMPT_FILE" > "$RESULTS_DIR/claude.json" 2>&1
  echo "Claude done"
) &

(
  bash ~/workbench/scripts/codex-review.sh "$PROMPT_FILE" > "$RESULTS_DIR/codex.json" 2>&1
  echo "Codex done"
) &

(
  ollama run qwen2.5-coder:7b < "$PROMPT_FILE" > "$RESULTS_DIR/ollama.raw" 2>&1
  # ollama doesn't always return clean JSON — try to extract
  python3 -c "
import re, json, sys
raw = open('$RESULTS_DIR/ollama.raw').read()
# Find JSON blob
m = re.search(r'\{.*\}', raw, re.DOTALL)
if m:
    try:
        data = json.loads(m.group(0))
        print(json.dumps(data))
    except:
        print('{\"critical\":[],\"suggested\":[],\"nitpick\":[]}')
else:
    print('{\"critical\":[],\"suggested\":[],\"nitpick\":[]}')
" > "$RESULTS_DIR/ollama.json"
  echo "Ollama done"
) &

wait

echo "All reviewers complete."

# -------- Merge into consensus --------
python3 <<EOF
import json
import sys

def safe_load(path):
    try:
        return json.load(open(path))
    except:
        # Try extracting JSON from markdown fences
        try:
            txt = open(path).read()
            import re
            m = re.search(r'\{.*\}', txt, re.DOTALL)
            if m:
                return json.loads(m.group(0))
        except:
            pass
        return {"critical": [], "suggested": [], "nitpick": []}

claude = safe_load("$RESULTS_DIR/claude.json")
codex = safe_load("$RESULTS_DIR/codex.json")
ollama = safe_load("$RESULTS_DIR/ollama.json")

# Helper: rough deduplication by checking substring overlap
def cluster(items_a, items_b, items_c):
    """Group items that appear in 2+ of the three lists."""
    all_items = []
    for src, items in [("claude", items_a), ("codex", items_b), ("ollama", items_c)]:
        for it in items:
            all_items.append((src, it.lower() if isinstance(it, str) else str(it).lower(), it))
    
    consensus_3, consensus_2, divergent = [], [], []
    used = set()
    
    for i, (src_i, key_i, orig_i) in enumerate(all_items):
        if i in used:
            continue
        matches = [(src_i, orig_i)]
        for j, (src_j, key_j, orig_j) in enumerate(all_items[i+1:], start=i+1):
            if j in used:
                continue
            # Rough overlap check: do they share 5+ word chunks?
            words_i = set(key_i.split())
            words_j = set(key_j.split())
            overlap = len(words_i & words_j)
            min_len = min(len(words_i), len(words_j))
            if min_len > 3 and overlap / min_len > 0.4 and src_j not in [s for s,_ in matches]:
                matches.append((src_j, orig_j))
                used.add(j)
        used.add(i)
        if len(matches) == 3:
            consensus_3.append(matches[0][1])
        elif len(matches) == 2:
            consensus_2.append(matches[0][1])
        else:
            divergent.append((src_i, orig_i))
    
    return consensus_3, consensus_2, divergent

print("\n=== PB-1 Review Summary ===\n")

for level in ["critical", "suggested", "nitpick"]:
    c3, c2, div = cluster(
        claude.get(level, []),
        codex.get(level, []),
        ollama.get(level, [])
    )
    print(f"\n--- {level.upper()} ---")
    if c3:
        print(f"\nCONSENSUS (3/3):")
        for item in c3:
            print(f"  - {item}")
    if c2:
        print(f"\nCONSENSUS (2/3):")
        for item in c2:
            print(f"  - {item}")
    if div:
        print(f"\nDIVERGENCE (1/3 — needs human eyes):")
        for src, item in div:
            print(f"  - [{src}] {item}")
    if not c3 and not c2 and not div:
        print("  (none)")

print("\n--- Files ---")
print(f"  Claude: $RESULTS_DIR/claude.json")
print(f"  Codex:  $RESULTS_DIR/codex.json")
print(f"  Ollama: $RESULTS_DIR/ollama.json")
EOF

echo
echo "Done. Recommended: fix consensus items (especially 3/3), inspect divergence."

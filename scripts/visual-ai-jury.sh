#!/usr/bin/env bash
# visual-ai-jury.sh — create evidence packets for PB-7.

set -uo pipefail

JURY_DIR="${DEVIN_VISUAL_AI_JURY_DIR:-$HOME/workbench/visual-ai-jury}"

usage() {
  cat <<'EOF'
Usage:
  visual-ai-jury init --id <id> --url <url> --goal <goal>
  visual-ai-jury note --id <id> --step <step> --observation <text>
  visual-ai-jury screenshot --id <id> --path <absolute-path> --label <label>
  visual-ai-jury console --id <id> --summary <text>
  visual-ai-jury packet --id <id>
  visual-ai-jury status --id <id>
  visual-ai-jury --self-test
EOF
}

timestamp() {
  date -Iseconds
}

fail() {
  echo "ERROR: $*" >&2
  exit 64
}

parse_id() {
  ID=""
  while [[ $# -gt 0 ]]; do
    case "$1" in
      --id) ID="${2:-}"; shift 2 ;;
      *) shift ;;
    esac
  done
  [ -n "$ID" ] || fail "--id is required"
}

packet_dir() {
  echo "$JURY_DIR/$ID"
}

append_line() {
  local file="$1"
  local text="$2"
  mkdir -p "$(dirname "$file")"
  printf '%s\n' "$text" >> "$file"
}

cmd_init() {
  ID=""
  URL=""
  GOAL=""
  while [[ $# -gt 0 ]]; do
    case "$1" in
      --id) ID="${2:-}"; shift 2 ;;
      --url) URL="${2:-}"; shift 2 ;;
      --goal) GOAL="${2:-}"; shift 2 ;;
      *) fail "unknown argument: $1" ;;
    esac
  done
  [ -n "$ID" ] || fail "--id is required"
  [ -n "$URL" ] || fail "--url is required"
  [ -n "$GOAL" ] || fail "--goal is required"

  DIR=$(packet_dir)
  mkdir -p "$DIR"/screenshots
  META_ID="$ID" META_URL="$URL" META_GOAL="$GOAL" META_CREATED_AT="$(timestamp)" python3 <<'PY' > "$DIR/meta.json"
import json
import os

print(json.dumps({
    "id": os.environ["META_ID"],
    "url": os.environ["META_URL"],
    "goal": os.environ["META_GOAL"],
    "created_at": os.environ["META_CREATED_AT"],
}, indent=2))
PY
  cat > "$DIR/notes.md" <<EOF
# Notes

EOF
  cat > "$DIR/console.md" <<EOF
# Console and Network Notes

EOF
  echo "Initialized Visual AI Jury packet at $DIR"
}

cmd_note() {
  ID=""
  STEP=""
  OBSERVATION=""
  while [[ $# -gt 0 ]]; do
    case "$1" in
      --id) ID="${2:-}"; shift 2 ;;
      --step) STEP="${2:-}"; shift 2 ;;
      --observation) OBSERVATION="${2:-}"; shift 2 ;;
      *) fail "unknown argument: $1" ;;
    esac
  done
  [ -n "$ID" ] || fail "--id is required"
  [ -n "$STEP" ] || fail "--step is required"
  [ -n "$OBSERVATION" ] || fail "--observation is required"
  append_line "$(packet_dir)/notes.md" "- $(timestamp) | **$STEP** | $OBSERVATION"
  echo "Noted observation for $ID"
}

cmd_screenshot() {
  ID=""
  PATH_IN=""
  LABEL=""
  while [[ $# -gt 0 ]]; do
    case "$1" in
      --id) ID="${2:-}"; shift 2 ;;
      --path) PATH_IN="${2:-}"; shift 2 ;;
      --label) LABEL="${2:-}"; shift 2 ;;
      *) fail "unknown argument: $1" ;;
    esac
  done
  [ -n "$ID" ] || fail "--id is required"
  [ -n "$PATH_IN" ] || fail "--path is required"
  [ -n "$LABEL" ] || fail "--label is required"
  [ -f "$PATH_IN" ] || fail "screenshot not found: $PATH_IN"

  DIR=$(packet_dir)
  mkdir -p "$DIR/screenshots"
  base=$(basename "$PATH_IN")
  safe_label=$(echo "$LABEL" | tr ' /' '__' | tr -cd '[:alnum:]_.-')
  dest="$DIR/screenshots/${safe_label}-${base}"
  cp "$PATH_IN" "$dest"
  append_line "$DIR/screenshots.md" "- $LABEL: $dest"
  echo "Added screenshot $dest"
}

cmd_console() {
  ID=""
  SUMMARY=""
  while [[ $# -gt 0 ]]; do
    case "$1" in
      --id) ID="${2:-}"; shift 2 ;;
      --summary) SUMMARY="${2:-}"; shift 2 ;;
      *) fail "unknown argument: $1" ;;
    esac
  done
  [ -n "$ID" ] || fail "--id is required"
  [ -n "$SUMMARY" ] || fail "--summary is required"
  append_line "$(packet_dir)/console.md" "- $(timestamp) | $SUMMARY"
  echo "Added console/network summary for $ID"
}

load_meta() {
  META="$(packet_dir)/meta.json"
  [ -f "$META" ] || fail "packet not initialized: $ID"
  eval "$(
    META="$META" python3 <<'PY'
import json
import os
import shlex

with open(os.environ["META"], encoding="utf-8") as handle:
    data = json.load(handle)

for key in ("url", "goal", "created_at"):
    print(f"{key.upper()}={shlex.quote(data[key])}")
PY
  )"
}

cmd_packet() {
  parse_id "$@"
  DIR=$(packet_dir)
  load_meta
  PACKET="$DIR/PACKET.md"
  cat > "$PACKET" <<EOF
# Visual AI Jury Packet — $ID

Created: $CREATED_AT
Target: $URL
Goal: $GOAL

## Steps and Observations

$(cat "$DIR/notes.md" 2>/dev/null || echo "_No notes captured._")

## Console and Network

$(cat "$DIR/console.md" 2>/dev/null || echo "_No console/network notes captured._")

## Screenshots

$(cat "$DIR/screenshots.md" 2>/dev/null || echo "_No screenshots attached._")

## Reviewer Instructions

You are reviewing a real browser QA packet. Return only JSON:

\`\`\`json
{
  "critical": ["Bug, broken flow, security/privacy issue"],
  "ux": ["Concrete UX/product issue with evidence"],
  "suggested": ["Useful improvement, not mandatory"],
  "discard": ["Things intentionally not worth changing"]
}
\`\`\`

Rules:

- Cite the step, screenshot label, console note, or observable evidence.
- Do not invent requirements.
- Do not include vague aesthetic preferences unless they block the stated goal.
- Prefer concrete fixes over broad redesigns.
EOF
  echo "Wrote $PACKET"
}

cmd_status() {
  parse_id "$@"
  DIR=$(packet_dir)
  [ -d "$DIR" ] || fail "packet not found: $ID"
  echo "Packet: $DIR"
  find "$DIR" -maxdepth 2 -type f | sort
}

self_test() {
  tmp=$(mktemp -d)
  DEVIN_VISUAL_AI_JURY_DIR="$tmp/jury" "$0" init --id smoke --url https://example.com --goal "Smoke test packet" >/dev/null || { rm -rf "$tmp"; exit 1; }
  DEVIN_VISUAL_AI_JURY_DIR="$tmp/jury" "$0" note --id smoke --step "Open page" --observation "Page loaded" >/dev/null || { rm -rf "$tmp"; exit 1; }
  DEVIN_VISUAL_AI_JURY_DIR="$tmp/jury" "$0" console --id smoke --summary "No console errors" >/dev/null || { rm -rf "$tmp"; exit 1; }
  screenshot="$tmp/smoke.png"
  printf 'not a real png but enough for packet plumbing\n' > "$screenshot"
  DEVIN_VISUAL_AI_JURY_DIR="$tmp/jury" "$0" screenshot --id smoke --path "$screenshot" --label "Landing page" >/dev/null || { rm -rf "$tmp"; exit 1; }
  DEVIN_VISUAL_AI_JURY_DIR="$tmp/jury" "$0" packet --id smoke >/dev/null || { rm -rf "$tmp"; exit 1; }
  test -s "$tmp/jury/smoke/PACKET.md" || { echo "FAIL: packet missing" >&2; rm -rf "$tmp"; exit 1; }
  grep -q "Visual AI Jury Packet" "$tmp/jury/smoke/PACKET.md" || { echo "FAIL: packet content missing" >&2; rm -rf "$tmp"; exit 1; }
  grep -q "Smoke test packet" "$tmp/jury/smoke/PACKET.md" || { echo "FAIL: metadata not preserved" >&2; rm -rf "$tmp"; exit 1; }
  rm -rf "$tmp"
  echo "visual-ai-jury self-test OK"
}

CMD="${1:-}"
shift || true

case "$CMD" in
  init) cmd_init "$@" ;;
  note) cmd_note "$@" ;;
  screenshot) cmd_screenshot "$@" ;;
  console) cmd_console "$@" ;;
  packet) cmd_packet "$@" ;;
  status) cmd_status "$@" ;;
  --self-test) self_test ;;
  *) usage; exit 64 ;;
esac

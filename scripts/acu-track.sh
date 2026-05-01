#!/usr/bin/env bash
# acu-track.sh — Track ACU/cost per task in a session.
#
# Usage:
#   acu-track "task description" -- <command-to-run>
#   acu-track --summary
#   acu-track --reset

set -uo pipefail

LOG_FILE="$HOME/workbench/cost-log.jsonl"
mkdir -p "$(dirname "$LOG_FILE")"
touch "$LOG_FILE"

# -------- Summary mode --------
if [ "${1:-}" = "--summary" ]; then
  echo "=== ACU Tracking Summary ==="
  echo
  
  python3 <<EOF
import json, sys
from datetime import datetime
from collections import defaultdict

log_file = "$LOG_FILE"
entries = []
for line in open(log_file):
    try:
        entries.append(json.loads(line))
    except:
        pass

if not entries:
    print("No tracked tasks yet.")
    sys.exit(0)

# Today's
today = datetime.now().strftime("%Y-%m-%d")
today_entries = [e for e in entries if e["ts"].startswith(today)]

print(f"Today ({today}):")
total_today_s = sum(e["duration_s"] for e in today_entries)
print(f"  Tasks: {len(today_entries)}")
print(f"  Total wall time: {total_today_s/60:.1f} min")
print(f"  Estimated ACU (rough: 1 ACU ≈ 15 min): {total_today_s/900:.1f}")

# Last 7 days
print(f"\nLast 7 days:")
total_7d_s = sum(e["duration_s"] for e in entries[-50:])  # rough
print(f"  Tasks: {len(entries[-50:])}")
print(f"  Total wall time: {total_7d_s/60:.1f} min")
print(f"  Estimated ACU: {total_7d_s/900:.1f}")

# Top tasks by duration
print("\nLongest tasks (today):")
today_sorted = sorted(today_entries, key=lambda e: -e["duration_s"])[:5]
for e in today_sorted:
    print(f"  {e['duration_s']:>5.0f}s  {e['task'][:60]}")
EOF
  exit 0
fi

# -------- Reset mode --------
if [ "${1:-}" = "--reset" ]; then
  read -r -p "Are you sure you want to reset cost log? [y/N] " confirm
  if [ "$confirm" = "y" ]; then
    BACKUP="$LOG_FILE.bak.$(date +%s)"
    mv "$LOG_FILE" "$BACKUP"
    touch "$LOG_FILE"
    echo "Reset done. Old log backed up to $BACKUP"
  else
    echo "Cancelled."
  fi
  exit 0
fi

# -------- Track mode --------
TASK="${1:-unnamed}"
shift || true

# Expect "--" before command
if [ "${1:-}" = "--" ]; then
  shift
fi

if [ $# -eq 0 ]; then
  echo "Usage: acu-track \"task name\" -- <command>"
  echo "       acu-track --summary"
  echo "       acu-track --reset"
  exit 64
fi

START=$(date +%s)
START_ISO=$(date -Iseconds)

echo "[acu-track] starting: $TASK"
"$@"
EXIT=$?
END=$(date +%s)
DURATION=$((END - START))

echo "[acu-track] finished: $TASK in ${DURATION}s (exit=$EXIT)"

# Append to log
python3 -c "
import json
print(json.dumps({
    'ts': '$START_ISO',
    'task': '''$TASK''',
    'duration_s': $DURATION,
    'exit_code': $EXIT,
    'end_ts': '$(date -Iseconds)'
}))
" >> "$LOG_FILE"

exit $EXIT

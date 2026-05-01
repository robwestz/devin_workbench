#!/usr/bin/env bash
# observer-loop.sh — Background loop spawned by observer.sh start.
# Polls condition, fires trigger when matched.

set -uo pipefail

ID="${1:-}"
if [ -z "$ID" ]; then exit 1; fi

OBS="$HOME/workbench/observers/$ID"
LOG="$OBS/event.log"
STATE="$OBS/state.json"

TARGET=$(jq -r '.target' "$STATE")
CONDITION=$(jq -r '.condition' "$STATE")
ON_TRIGGER=$(jq -r '.on_trigger' "$STATE")
INTERVAL=$(jq -r '.interval_s' "$STATE")
DUR_S=$(jq -r '.duration_s' "$STATE")

echo "[$(date -Iseconds)] Observer $ID started" > "$LOG"
echo "  Target: $TARGET" >> "$LOG"
echo "  Condition: $CONDITION" >> "$LOG"

START=$(date +%s)
END=$(( START + DUR_S ))

check_condition() {
  case "$CONDITION" in
    "status_code="*)
      local expected=${CONDITION#status_code=}
      local actual=$(curl -s -o /dev/null -w "%{http_code}" --max-time 10 "$TARGET" 2>/dev/null || echo "000")
      [ "$actual" = "$expected" ]
      ;;
    "status_code!="*)
      local expected=${CONDITION#status_code!=}
      local actual=$(curl -s -o /dev/null -w "%{http_code}" --max-time 10 "$TARGET" 2>/dev/null || echo "000")
      [ "$actual" != "$expected" ]
      ;;
    "text_contains="*)
      local needle=${CONDITION#text_contains=}
      curl -s --max-time 10 "$TARGET" 2>/dev/null | grep -q "$needle"
      ;;
    "latency>"*)
      local threshold_ms=${CONDITION#latency>}
      local actual_s=$(curl -s -o /dev/null -w "%{time_total}" --max-time 30 "$TARGET" 2>/dev/null || echo "999")
      local actual_ms=$(echo "$actual_s * 1000 / 1" | bc)
      [ "$actual_ms" -gt "$threshold_ms" ]
      ;;
    "process_exits")
      ! pgrep -f "$TARGET" >/dev/null
      ;;
    *)
      echo "[$(date -Iseconds)] ERROR: unknown condition $CONDITION" >> "$LOG"
      return 1
      ;;
  esac
}

handle_trigger() {
  local snapshot_dir="$OBS/$(date +%Y%m%d-%H%M%S)"
  mkdir -p "$snapshot_dir"
  
  echo "[$(date -Iseconds)] TRIGGERED — capturing to $snapshot_dir" >> "$LOG"
  
  # Always capture
  if [[ "$TARGET" == http* ]]; then
    curl -sL --max-time 30 "$TARGET" -o "$snapshot_dir/response.html" 2>/dev/null || true
    curl -s -I --max-time 10 "$TARGET" > "$snapshot_dir/headers.txt" 2>/dev/null || true
  fi
  
  date -Iseconds > "$snapshot_dir/timestamp"
  
  # Increment trigger count in state
  jq '.trigger_count += 1' "$STATE" > "$STATE.tmp" && mv "$STATE.tmp" "$STATE"
  
  case "$ON_TRIGGER" in
    notify|capture-and-notify)
      # Slack/Discord webhook if configured
      if [ -n "${OBSERVER_WEBHOOK_URL:-}" ]; then
        curl -X POST -H 'Content-Type: application/json' \
          -d "{\"text\":\"Observer $ID triggered on $TARGET at $(date -Iseconds)\"}" \
          "$OBSERVER_WEBHOOK_URL" >/dev/null 2>&1 || true
      fi
      ;;
    incident)
      echo "[$(date -Iseconds)] Entering incident mode (RCA — manual continuation)" >> "$LOG"
      ;;
  esac
}

while [ "$(date +%s)" -lt "$END" ]; do
  if check_condition; then
    handle_trigger
  fi
  echo "[$(date -Iseconds)] check ok" >> "$LOG"
  sleep "$INTERVAL"
done

echo "[$(date -Iseconds)] Observer $ID duration ended" >> "$LOG"
jq '.status = "completed"' "$STATE" > "$STATE.tmp" && mv "$STATE.tmp" "$STATE"

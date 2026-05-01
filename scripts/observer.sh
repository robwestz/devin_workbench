#!/usr/bin/env bash
# observer.sh — Long-running observer for PB-5.
# Watches a URL or process for a condition, takes action when triggered.
#
# Usage:
#   observer.sh start --id <id> --target <url-or-process> --condition <spec> --on-trigger <action> --duration <time> --interval <s>
#   observer.sh list
#   observer.sh stop <id>
#   observer.sh logs <id>

set -uo pipefail

OBS_DIR="$HOME/workbench/observers"
mkdir -p "$OBS_DIR"

CMD="${1:-}"
shift || true

case "$CMD" in
  list)
    echo "=== Active observers ==="
    if [ -d "$OBS_DIR" ]; then
      for d in "$OBS_DIR"/*/; do
        [ -d "$d" ] || continue
        id=$(basename "$d")
        if [ -f "$d/state.json" ]; then
          status=$(jq -r '.status' "$d/state.json" 2>/dev/null || echo "unknown")
          target=$(jq -r '.target' "$d/state.json" 2>/dev/null || echo "?")
          echo "  $id  [$status]  $target"
        fi
      done
    fi
    ;;
    
  stop)
    ID="${1:-}"
    if [ -z "$ID" ]; then echo "Usage: observer.sh stop <id>"; exit 64; fi
    
    if [ -f "$OBS_DIR/$ID/pid" ]; then
      pid=$(cat "$OBS_DIR/$ID/pid")
      kill "$pid" 2>/dev/null && echo "Stopped observer $ID (pid $pid)" || echo "Observer $ID was not running"
      rm "$OBS_DIR/$ID/pid"
    fi
    
    if [ -f "$OBS_DIR/$ID/state.json" ]; then
      jq '.status = "stopped"' "$OBS_DIR/$ID/state.json" > "$OBS_DIR/$ID/state.tmp"
      mv "$OBS_DIR/$ID/state.tmp" "$OBS_DIR/$ID/state.json"
    fi
    ;;
    
  logs)
    ID="${1:-}"
    if [ -z "$ID" ]; then echo "Usage: observer.sh logs <id>"; exit 64; fi
    
    if [ -f "$OBS_DIR/$ID/event.log" ]; then
      tail -f "$OBS_DIR/$ID/event.log"
    else
      echo "No log file for observer $ID"
    fi
    ;;
    
  start)
    # Parse start args
    ID=""
    TARGET=""
    CONDITION=""
    ON_TRIGGER="capture"
    DURATION="1h"
    INTERVAL=30
    
    while [[ $# -gt 0 ]]; do
      case $1 in
        --id) ID=$2; shift 2 ;;
        --target) TARGET=$2; shift 2 ;;
        --condition) CONDITION=$2; shift 2 ;;
        --on-trigger) ON_TRIGGER=$2; shift 2 ;;
        --duration) DURATION=$2; shift 2 ;;
        --interval) INTERVAL=$2; shift 2 ;;
        *) shift ;;
      esac
    done
    
    if [ -z "$ID" ] || [ -z "$TARGET" ] || [ -z "$CONDITION" ]; then
      echo "Usage: observer.sh start --id <id> --target <url|process> --condition <spec>" >&2
      echo "       [--on-trigger capture|notify|capture-and-notify|incident]" >&2
      echo "       [--duration 4h] [--interval 30]" >&2
      exit 64
    fi
    
    OBS="$OBS_DIR/$ID"
    mkdir -p "$OBS"
    
    # Convert duration to seconds
    case $DURATION in
      *h) DUR_S=$(( ${DURATION%h} * 3600 )) ;;
      *m) DUR_S=$(( ${DURATION%m} * 60 )) ;;
      *s) DUR_S=${DURATION%s} ;;
      *) DUR_S=3600 ;;
    esac
    
    # Save state
    cat > "$OBS/state.json" <<EOF
{
  "id": "$ID",
  "target": "$TARGET",
  "condition": "$CONDITION",
  "on_trigger": "$ON_TRIGGER",
  "started_at": "$(date -Iseconds)",
  "duration_s": $DUR_S,
  "interval_s": $INTERVAL,
  "status": "running",
  "trigger_count": 0
}
EOF
    
    # Spawn watcher in background via tmux session
    tmux new-session -d -s "obs-$ID" "bash $HOME/workbench/scripts/observer-loop.sh '$ID'"
    
    # Save PID (tmux session — use list to find)
    tmux list-sessions -F '#{session_name} #{pid}' | grep "obs-$ID " | awk '{print $2}' > "$OBS/pid"
    
    echo "Started observer '$ID' in tmux session 'obs-$ID'"
    echo "  Target: $TARGET"
    echo "  Condition: $CONDITION"
    echo "  Duration: $DURATION ($DUR_S sec)"
    echo "  Interval: ${INTERVAL}s"
    echo
    echo "Logs: bash observer.sh logs $ID"
    echo "Stop: bash observer.sh stop $ID"
    ;;
    
  *)
    echo "Usage: observer.sh {start|list|stop|logs} ..." >&2
    exit 64
    ;;
esac

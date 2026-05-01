#!/usr/bin/env bash
# codex-review.sh — single-reviewer wrapper for Codex CLI.

set -uo pipefail

PROMPT_FILE="${1:-}"

if [ -z "$PROMPT_FILE" ] || [ ! -f "$PROMPT_FILE" ]; then
  echo "Usage: $0 <prompt-file>" >&2
  exit 64
fi

if ! command -v codex &>/dev/null; then
  echo '{"critical":["codex CLI not installed in snapshot"],"suggested":[],"nitpick":[]}' >&2
  exit 1
fi

# Codex CLI picks up auth from OPENAI_API_KEY env
codex --prompt "$(cat "$PROMPT_FILE")" --max-tokens 4000 2>/dev/null

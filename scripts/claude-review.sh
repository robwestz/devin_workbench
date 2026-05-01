#!/usr/bin/env bash
# claude-review.sh — single-reviewer wrapper for Claude Code.
# Reads prompt from file (or stdin), outputs JSON.

set -uo pipefail

PROMPT_FILE="${1:-}"

if [ -z "$PROMPT_FILE" ] || [ ! -f "$PROMPT_FILE" ]; then
  echo "Usage: $0 <prompt-file>" >&2
  exit 64
fi

# Claude Code picks up auth from env (ANTHROPIC_API_KEY) or ~/.claude/ — see workbench AUTH-PREFLIGHT
if ! command -v claude &>/dev/null; then
  echo '{"critical":["claude CLI not installed in snapshot"],"suggested":[],"nitpick":[]}' >&2
  exit 1
fi

# Run with structured output expectation
claude -p "$(cat "$PROMPT_FILE")" --max-tokens 4000 2>/dev/null

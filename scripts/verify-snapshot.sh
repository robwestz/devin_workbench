#!/usr/bin/env bash
# verify-snapshot.sh — Run after snapshot build to verify all 9 layers work.
#
# Output is markdown, suitable for committing as INSTALL_LOG.md.

set -uo pipefail

PASS=0
FAIL=0
WARN=0

check() {
  local label=$1
  local cmd=$2
  if eval "$cmd" >/dev/null 2>&1; then
    echo "- ✓ $label"
    PASS=$((PASS+1))
  else
    echo "- ✗ $label  ($cmd)"
    FAIL=$((FAIL+1))
  fi
}

warn_check() {
  local label=$1
  local cmd=$2
  if eval "$cmd" >/dev/null 2>&1; then
    echo "- ✓ $label"
    PASS=$((PASS+1))
  else
    echo "- ⚠ $label (optional, $cmd)"
    WARN=$((WARN+1))
  fi
}

cat <<EOF
# INSTALL_LOG

Generated: $(date -Iseconds)
Verifier: scripts/verify-snapshot.sh

## Layer 0 — Base hardening

EOF

check "git" "git --version"
check "curl" "curl --version"
check "jq" "jq --version"
check "ripgrep" "rg --version"
check "fd" "fd --version"
check "fzf" "fzf --version"
check "tmux" "tmux -V"
check "pandoc" "pandoc --version"
check "bc" "echo 1+1 | bc"

cat <<EOF

## Layer 1 — Language runtimes

EOF

check "mise" "mise --version"
check "Python 3.13" "python3.13 --version"
check "Node v22+" "node --version | grep -E 'v(22|24)'"
check "Go 1.24" "go version | grep go1.24"
check "Rust stable" "rustc --version"
check "Bun" "bun --version"
check "uv" "uv --version"
check "pnpm" "pnpm --version"
check "fastapi installed" "python3 -c 'import fastapi'"
check "pydantic installed" "python3 -c 'import pydantic'"
check "litellm installed" "python3 -c 'import litellm'"
check "instructor installed" "python3 -c 'import instructor'"
check "loguru installed" "python3 -c 'import loguru'"
check "playwright installed" "playwright --version"
check "pytest installed" "pytest --version"
check "ruff installed" "ruff --version"
check "mypy installed" "mypy --version"
check "typescript globally" "tsc --version"
check "prettier globally" "prettier --version"
check "eslint globally" "eslint --version"

cat <<EOF

## Layer 2 — Data services

EOF

check "Postgres 16" "psql --version | grep 16"
check "Postgres running" "psql -d devbench -c 'SELECT 1'"
check "Redis" "redis-cli --version"
check "Redis running" "redis-cli ping | grep PONG"
check "Docker" "docker --version"
check "Qdrant image pulled" "docker image inspect qdrant/qdrant"
check "DuckDB" "duckdb --version"

cat <<EOF

## Layer 3 — Browser & visual test

EOF

check "Playwright chromium" "ls ~/.cache/ms-playwright/chromium-*"
check "Playwright firefox" "ls ~/.cache/ms-playwright/firefox-*"
check "Playwright webkit" "ls ~/.cache/ms-playwright/webkit-*"
check "reg-cli" "reg-cli --version"
check "bubblewrap (sandbox)" "bwrap --version"

cat <<EOF

## Layer 4 — AI stack

EOF

check "Claude Code CLI" "claude --version"
check "Codex CLI" "codex --version"
check "Ollama installed" "ollama --version"
check "Ollama service running" "systemctl is-active ollama"
check "llama3.2:3b pulled" "ollama list | grep llama3.2"
check "qwen2.5-coder:7b pulled" "ollama list | grep qwen2.5-coder"
check "aichat" "aichat --info"

cat <<EOF

## Layer 5 — Observability

EOF

check ".tmux.conf exists" "[ -f ~/.tmux.conf ]"
check "asciinema" "asciinema --version"
check "bottom (btm)" "btm --version"
check "lazygit" "lazygit --version"

cat <<EOF

## Layer 6 — Quality gates

EOF

check "gitleaks" "gitleaks version"
check "pre-commit" "pre-commit --version"
check "git templates configured" "git config --global init.templateDir | grep git-templates"

cat <<EOF

## Layer 7 — Secrets & env

EOF

check "direnv" "direnv version"
check "sops" "sops --version"
check "age" "age --version"
warn_check "1Password CLI" "op --version"

cat <<EOF

## Layer 8 — Workbench config

EOF

check "Workbench cloned at ~/workbench" "[ -d ~/workbench ]"
check "Workbench has SPEC.md" "[ -f ~/workbench/SPEC.md ]"
check "LESSONS.md exists" "[ -f ~/workbench/LESSONS.md ]"
check "Playbooks directory" "[ -d ~/workbench/playbooks ] && [ \"\$(ls ~/workbench/playbooks | wc -l)\" -ge 6 ]"
check "Scripts symlinked" "[ -L ~/.local/bin/three-ai-consensus ]"
check "bashrc.d sourced" "grep -q bashrc.d ~/.bashrc"

cat <<EOF

## Self-tests

EOF

check "three-ai-consensus self-test" "bash ~/workbench/scripts/three-ai-consensus.sh --self-test 2>&1 | grep -q 'Done'"
warn_check "visual-diff self-test" "bash ~/workbench/scripts/visual-diff.sh --self-test 2>&1 | grep -q 'Report'"
check "acu-track works" "bash ~/workbench/scripts/acu-track.sh 'verify-test' -- echo ok"

cat <<EOF

## Summary

- ✓ Pass: $PASS
- ✗ Fail: $FAIL
- ⚠ Warn (optional): $WARN

$(if [ $FAIL -eq 0 ]; then
  echo "**Status:** READY. Save VM as 'compounding-workbench-v1.0'."
else
  echo "**Status:** NOT READY. Fix $FAIL failures before saving snapshot."
fi)

EOF

exit $FAIL

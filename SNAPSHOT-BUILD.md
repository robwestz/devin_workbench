# SNAPSHOT-BUILD.md

> Layered installation guide for building the Compounding Workbench snapshot the first time.
>
> Devin runs this in a one-time snapshot-build session. Each layer is verifiable independently. Do not move to next layer until current layer verifies clean.

---

## Pre-build checklist

Before starting:

- [ ] Devin's machine settings has a fresh Ubuntu 22.04 base
- [ ] User has provided the URL of this repo (workbench source)
- [ ] User has confirmed which optional tools to include (1Password CLI? sops?)
- [ ] User understands snapshot build will take 60-90 minutes and ~70 ACU

---

## Layer 0 — Base hardening

```bash
# Update + base utilities
sudo apt update && sudo apt upgrade -y
sudo apt install -y \
  build-essential git curl wget jq unzip zip \
  tmux htop tree ripgrep fd-find bat fzf \
  postgresql-client redis-tools \
  imagemagick ffmpeg \
  software-properties-common ca-certificates gnupg lsb-release \
  python3-pip python3-venv \
  direnv pandoc bc

# Ubuntu renames these — alias them
mkdir -p ~/.local/bin
ln -sf $(which fdfind) ~/.local/bin/fd
ln -sf $(which batcat) ~/.local/bin/bat
echo 'export PATH="$HOME/.local/bin:$PATH"' >> ~/.bashrc
```

**Verify:**
```bash
fd --version && bat --version && rg --version && jq --version
# All should return version info, no errors
```

---

## Layer 1 — Language runtimes

```bash
# mise for Python/Node/Go version management
curl https://mise.run | sh
echo 'eval "$(~/.local/bin/mise activate bash)"' >> ~/.bashrc
source ~/.bashrc

# Python versions
mise install python@3.11 python@3.12 python@3.13
mise global python@3.13

# Node versions
mise install node@20 node@22 node@24
mise global node@22

# Go versions
mise install go@1.23 go@1.24
mise global go@1.24

# Rust separately (rustup is the canonical installer)
curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh -s -- -y --default-toolchain stable
source "$HOME/.cargo/env"
rustup toolchain install nightly

# Bun
curl -fsSL https://bun.sh/install | bash

# uv (Python package manager — faster than pip)
curl -LsSf https://astral.sh/uv/install.sh | sh

# pnpm (Node package manager — preferred over npm)
npm install -g pnpm
```

Pre-warm Python and Node caches with packages used everywhere:

```bash
uv pip install --system \
  fastapi pydantic litellm instructor loguru rich \
  playwright pytest pytest-cov hypothesis httpx \
  ruff mypy pre-commit ipython

pnpm install -g typescript prettier eslint vercel @anthropic-ai/sdk

# Playwright browsers (this takes 5+ min but only once)
playwright install --with-deps chromium firefox webkit
```

**Verify:**
```bash
python3.13 --version  # 3.13.x
node --version        # v22.x
go version            # go1.24.x
rustc --version       # 1.x.x stable
bun --version         # >0.x
uv --version
pnpm --version
playwright --version
```

---

## Layer 2 — Data services

```bash
# Postgres 16
sudo sh -c 'echo "deb http://apt.postgresql.org/pub/repos/apt $(lsb_release -cs)-pgdg main" > /etc/apt/sources.list.d/pgdg.list'
wget --quiet -O - https://www.postgresql.org/media/keys/ACCC4CF8.asc | sudo apt-key add -
sudo apt update
sudo apt install -y postgresql-16

sudo systemctl enable postgresql
sudo systemctl start postgresql
sudo -u postgres createuser -s ubuntu
sudo -u postgres createdb devbench

# Redis
sudo apt install -y redis-server
sudo systemctl enable redis-server

# Qdrant via docker (assuming docker is in base — install if not)
sudo apt install -y docker.io
sudo usermod -aG docker ubuntu
docker pull qdrant/qdrant:latest

# DuckDB CLI
curl -L https://github.com/duckdb/duckdb/releases/latest/download/duckdb_cli-linux-amd64.zip -o /tmp/duckdb.zip
sudo unzip -o /tmp/duckdb.zip -d /usr/local/bin/
```

**Verify:**
```bash
psql -d devbench -c 'SELECT version();'
redis-cli ping       # PONG
docker --version
duckdb --version
```

---

## Layer 3 — Browser & visual test

```bash
# Playwright is already installed via Layer 1; ensure browsers are present
playwright install chromium firefox webkit

# Pixelmatch + reg-cli for visual diff
pnpm install -g reg-cli pixelmatch-cli

# bubblewrap for sandboxing (used by Larder validator)
sudo apt install -y bubblewrap
```

**Verify:**
```bash
playwright --version
reg-cli --version
bwrap --version
```

---

## Layer 4 — AI stack

```bash
# Claude Code CLI — Devin will invoke this for code review and adapter generation
curl -fsSL https://claude.ai/install.sh | bash
# Verify path
which claude

# Codex CLI (second-opinion reviewer)
npm install -g @openai/codex

# LiteLLM as universal LLM router
uv pip install --system 'litellm[proxy]'

# Instructor for structured output
uv pip install --system instructor

# Ollama for local models
curl -fsSL https://ollama.com/install.sh | sh
sudo systemctl enable ollama
sudo systemctl start ollama

# Pull lightweight models — these persist in snapshot
ollama pull llama3.2:3b      # ~2GB, snappy general chat
ollama pull qwen2.5-coder:7b # ~5GB, code-focused

# aichat — universal LLM CLI
cargo install aichat
```

**IMPORTANT:** Auth keys for Claude Code, Codex, and any LiteLLM-backed model are NOT baked into snapshot. They are injected per-session via Devin's secrets:

- `ANTHROPIC_API_KEY`
- `OPENAI_API_KEY`
- (LiteLLM picks them up automatically)

For Claude Code: if user mounted Max subscription credentials, they live in `~/.claude/credentials.json` — copied per-session, not baked.

**Verify (without keys, just installation):**
```bash
claude --version
codex --version
ollama list           # shows llama3.2:3b and qwen2.5-coder:7b
aichat --info
```

---

## Layer 5 — Observability & persistent sessions

```bash
# tmux config
cat > ~/.tmux.conf <<'EOF'
set -g mouse on
set -g history-limit 100000
setw -g mode-keys vi
set -g default-terminal "screen-256color"

# Sane pane navigation
bind h select-pane -L
bind j select-pane -D
bind k select-pane -U
bind l select-pane -R
EOF

# asciinema for session recording
sudo apt install -y asciinema

# bottom — htop replacement
cargo install bottom

# lazygit
LAZYGIT_VERSION=$(curl -s "https://api.github.com/repos/jesseduffield/lazygit/releases/latest" | grep -Po '"tag_name": "v\K[^"]*')
curl -Lo /tmp/lazygit.tar.gz "https://github.com/jesseduffield/lazygit/releases/latest/download/lazygit_${LAZYGIT_VERSION}_Linux_x86_64.tar.gz"
tar xf /tmp/lazygit.tar.gz -C /tmp lazygit
sudo install /tmp/lazygit /usr/local/bin
```

**Verify:**
```bash
tmux -V
asciinema --version
btm --version
lazygit --version
```

---

## Layer 6 — Quality gates

```bash
# Already installed via Layer 1: ruff, mypy, pytest, hypothesis, pre-commit
# Already installed via Layer 1: typescript-eslint, prettier, vitest

# gitleaks for secret-scanning before commit
GITLEAKS_VERSION=$(curl -s "https://api.github.com/repos/gitleaks/gitleaks/releases/latest" | grep -Po '"tag_name": "v\K[^"]*')
curl -L "https://github.com/gitleaks/gitleaks/releases/latest/download/gitleaks_${GITLEAKS_VERSION}_linux_x64.tar.gz" | sudo tar -xz -C /usr/local/bin gitleaks

# Set up global pre-commit template (we'll fill in the hook in Layer 9)
mkdir -p ~/.git-templates/hooks
git config --global init.templateDir ~/.git-templates
```

**Verify:**
```bash
ruff --version
mypy --version
pre-commit --version
gitleaks version
```

---

## Layer 7 — Secrets & per-project env

```bash
# direnv was installed in Layer 0; activate hook
echo 'eval "$(direnv hook bash)"' >> ~/.bashrc

# 1Password CLI (optional — only if user uses 1Password)
# Uncomment if needed:
# curl -sSfO https://downloads.1password.com/linux/debian/amd64/stable/1password-cli-amd64-latest.deb
# sudo dpkg -i 1password-cli-amd64-latest.deb

# sops + age for git-committed encrypted env files
curl -L https://github.com/getsops/sops/releases/latest/download/sops-v3.9.1.linux.amd64 -o /tmp/sops
sudo install /tmp/sops /usr/local/bin/sops
sudo apt install -y age
```

**Verify:**
```bash
direnv version
sops --version
age --version
```

---

## Layer 8 — Workbench config

This is where the workbench repo gets cloned and integrated.

```bash
# Clone this repo
git clone <REPO_URL> ~/workbench

# Install workbench bashrc additions
mkdir -p ~/.bashrc.d
cp ~/workbench/.bashrc.d/* ~/.bashrc.d/ 2>/dev/null || true

# Hook ~/.bashrc to source ~/.bashrc.d
if ! grep -q "bashrc.d" ~/.bashrc; then
  cat >> ~/.bashrc <<'EOF'

# Workbench bashrc additions
if [ -d ~/.bashrc.d ]; then
  for f in ~/.bashrc.d/*.sh; do
    [ -r "$f" ] && . "$f"
  done
fi
EOF
fi

# Workbench scripts on PATH
mkdir -p ~/.local/bin
for script in ~/workbench/scripts/*.sh; do
  ln -sf "$script" ~/.local/bin/$(basename "$script" .sh)
done

# Install pre-commit hook globally
cp ~/workbench/.git-templates/hooks/pre-commit ~/.git-templates/hooks/
chmod +x ~/.git-templates/hooks/pre-commit
```

**Verify:**
```bash
source ~/.bashrc
which three-ai-consensus  # should resolve to ~/.local/bin/three-ai-consensus
which acu-track
ls ~/workbench/playbooks/  # 6 PB-*.md files
```

---

## Layer 9 — Final verification

Run the verification script to confirm everything works:

```bash
bash ~/workbench/scripts/verify-snapshot.sh > ~/workbench/INSTALL_LOG.md
```

This script checks every binary, every service, every script. If any check fails, the snapshot is not ready.

---

## Final commit & save

```bash
cd ~/workbench
git add INSTALL_LOG.md
git commit -m "Snapshot v1.0-base initial install verified"
git push origin main

# Now save the snapshot in Devin's machine settings as "compounding-workbench-v1.0"
```

---

## Snapshot update protocol (for future versions)

When a snapshot update is approved (e.g., via PB-4 self-improvement sweep):

1. Update `SPEC.md` with new tool / change
2. Update `SNAPSHOT-BUILD.md` with new install steps for the diff
3. Run a fresh snapshot-build session, applying ONLY the diff (not full rebuild)
4. Bump version: v1.0 → v1.1
5. Commit `INSTALL_LOG.md` with diff results
6. Save new snapshot

Full rebuild (v1 → v2) only when major OS upgrade or breaking changes.

---

## ACU budget

| Layer | Estimated ACU |
|---|---|
| Layer 0 | 2 |
| Layer 1 | 8 (lots of downloads) |
| Layer 2 | 5 |
| Layer 3 | 3 |
| Layer 4 | 12 (ollama models are biggest pull) |
| Layer 5 | 2 |
| Layer 6 | 1 |
| Layer 7 | 1 |
| Layer 8 | 2 |
| Layer 9 (verify) | 2 |
| Devin orchestration | 5 |
| **Total** | **~43 ACU** |

If snapshot build crosses 60 ACU: stop, post status, ask human. Something is wrong.

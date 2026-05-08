# SPEC — Compounding Workbench

> What the workbench is, what it includes, what's hard rules.

---

## North Star

> Devin starts every new session with:
>
> (a) **zero setup time** — all languages, databases, browsers, AI CLIs already installed and working,
> (b) **three AI colleagues on speed-dial** — Claude Code, Codex CLI, local ollama — as tools, not chat windows,
> (c) **lessons from previous sessions already loaded** — what worked, what didn't, what to avoid,
> (d) **a quality gate that makes shipping bad code hard** — pre-commit, mypy, ruff, eslint, playwright tests ready to run with one command,
> (e) **cost telemetry** that logs ACU per task so you know in retrospect what was worth it.

---

## Anti-Goals

- **Not** a clone of your local dev environment. Devin is a colleague, not a mirror of you.
- **Not** a place where all your secrets are stored. Secrets are injected per session via env, never baked into snapshot.
- **Not** somewhere you run autonomous production deploys without approval.
- **Not** an "AI orgy" where Devin chats with Claude and Codex in natural language. Cross-AI happens via **structured prompts → JSON output**, not conversations.
- **Not** a GUI-heavy environment with VS Code, Cursor, etc. inside Devin. CLI-first.

---

## Storage Principle — what's inherited, what's per-session

| Layer | Location | Examples | Persistent? |
|---|---|---|---|
| **Snapshot** | Ubuntu image | Python, Node, Postgres binaries, Claude CLI, ollama weights | Yes, inherited every session |
| **Workbench repo** | `~/workbench/` | LESSONS.md, STYLE.md, playbooks, scripts | Yes, but updated through commits |
| **Per-project** | `~/projects/<name>/` | Project code, `.envrc`, `node_modules` (cached) | Per-session, but `~/.cache` inherited |
| **Secrets** | env vars | `OPENAI_API_KEY`, `ANTHROPIC_API_KEY`, `GH_TOKEN` | Per-session, injected by user |
| **Lessons** | `~/workbench/LESSONS.md` | "X took 8 min, fix is Y" | Yes, grows monotonically |

> **The rule:** if a lesson doesn't make it into LESSONS.md, it didn't happen. Devin must write to that file at every session's end.

---

## Snapshot Layers

The snapshot is built once (initial build session) and updated occasionally. Each layer is independently verifiable.

### Layer 0 — Base hardening
Ubuntu 22.04, basic CLI tools (git, curl, jq, ripgrep, fd, fzf, tmux, htop, etc.).

### Layer 1 — Language runtimes (multi-version, pinned)
- mise for Python/Node/Go version management
- Python 3.11, 3.12, 3.13
- Node 20 LTS, 22, 24
- Go 1.23, 1.24
- Rust stable + nightly
- Bun, uv, pnpm

### Layer 2 — Data services
- Postgres 16 (autostart via systemd)
- Redis
- Qdrant via docker
- DuckDB CLI

### Layer 3 — Browser & visual test
- Playwright with chromium, firefox, webkit
- pixelmatch + reg-cli for visual diff

### Layer 4 — AI stack
- **Claude Code CLI** (auth via env in session, not baked in)
- **Codex CLI** (OpenAI's coding agent)
- **LiteLLM** (universal LLM router)
- **Instructor** (structured output)
- **Ollama** with llama3.2:3b + qwen2.5-coder:7b (weights persist)
- **aichat** (universal CLI for all LLM providers)

### Layer 5 — Observability & persistence
- tmux with custom config
- asciinema for session recording
- bottom (htop on steroids)
- lazygit

### Layer 6 — Quality gates
- ruff, mypy, pytest, hypothesis (Python)
- typescript-eslint, prettier, vitest (Node)
- pre-commit (universal)
- gitleaks for secret scanning

### Layer 7 — Secrets & per-project env
- direnv
- 1Password CLI (optional)
- sops + age for git-encrypted env

### Layer 8 — Devin-personal config
- `.bashrc.d/` with workbench aliases
- `pj <name>` function for project navigation
- `wb`, `lessons`, `claude-review`, `acu-track` aliases

### Layer 9 — Hooks
- This repo cloned at `~/workbench/`
- `~/.bashrc` sources `~/workbench/.bashrc.d/`

See **`SNAPSHOT-BUILD.md`** for the actual install commands.

---

## Cross-cutting Constraints

- **No LLM calls outside LiteLLM layer.** Verifier flags and blocks PRs that violate this.
- **No new entry point in orchestrator without atomic primitive.** Composition happens in workflow definitions, not in orchestrator code.
- **Every agent action logs to `agent_actions` table BEFORE execution**, not after.
- **Reproducibility:** every LLM call logs prompt + model + temperature + version. A run can be replayed (or diffed) months later.
- **Cost cap:** every project has a token/dollar budget. Scout, Engineer, Judge respect it. Cap reached → graceful degrade, not hard crash.
- **No new skills invented in runtime.** If the agent needs a new capability = pause, escalate to build-time.

---

## Playbooks

The workflow recipes shipped with the workbench. Each has a markdown file in `playbooks/`:

| Playbook | Trigger | Purpose |
|---|---|---|
| **PB-1** | "Review this PR with the panel" | Three AI consensus review |
| **PB-2** | "Generate adapter for <api-doc>" | Adapter Factory run (integrates with Larder) |
| **PB-3** | "Visual diff <url>" | Before/after visual regression |
| **PB-4** | Weekly cron, or "improve yourself" | Self-improvement sweep based on LESSONS.md |
| **PB-5** | "Watch <url> for <condition>" | Long-running observer task |
| **PB-6** | "Bootstrap project <name>" | Scaffold new project from blueprint |
| **PB-7** | "Run visual AI jury on <url>" | Desktop QA + cross-AI product review |

PB-1 is the most-used code gate. PB-2 is the integration point with Larder. PB-4 is what makes the workbench compounding. PB-7 is the "gamechanger" layer: Devin uses its desktop like a human QA lead, then routes evidence through AI reviewers.

---

## What's NOT in the workbench

- No specific projects (those live in `~/projects/`)
- No vault items (those live in Larder, separate)
- No production-grade experiment harnesses without a playbook and kill/rollback path
- No production deployment infrastructure (CI/CD lives in each project)

---

## Hard Rules

- **No tools installed that aren't in this SPEC.** Edit SPEC first, then rebuild snapshot.
- **No LESSONS.md skips.** Sessions without lessons are wasted sessions.
- **No bypassing pre-commit hooks.**
- **No editing snapshot directly.** Edit this repo, rebuild snapshot from spec.
- **No baking secrets into snapshot.** Secrets per-session via env.

---

## When to update SPEC

- A new tool proves useful in 3+ sessions → propose for Layer N
- An existing tool causes pain → demote / replace, document why
- A playbook becomes hot → make it a shortcut on Devin's homepage
- A playbook is unused for 90 days → archive

The user reviews proposed SPEC changes via PB-4. Devin doesn't unilaterally edit SPEC.

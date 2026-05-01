# Devin Workbench

> Source-of-truth repo for Devin's Compounding Workbench — a Golden Snapshot that compounds in value over time.
>
> Devin clones this repo at session start. It contains operational knowledge, playbooks, scripts, and templates that the snapshot expects.

## What this is

This is **not** the snapshot itself (the snapshot is an Ubuntu image in Devin's machine settings). This is the **persistent layer** that lives outside the snapshot and is checked out fresh each session.

Why both?
- Snapshot has the binaries (Python, Node, Postgres, Claude Code CLI, ollama, etc.) — heavy stuff that doesn't change often
- This repo has the lessons, playbooks, and scripts — light stuff that evolves every session

When Devin starts a session, the snapshot wakes up with everything installed AND this repo cloned at `~/workbench/`.

## Read order for an agent (Devin or future Claude)

1. **`SPEC.md`** — what the workbench is, what it includes, what's hard rules
2. **`SNAPSHOT-BUILD.md`** — the layered installation guide for building the snapshot the first time
3. **`LESSONS.md`** — what we learned from past sessions (heaviest weight; read every session)
4. **`STYLE.md`**, **`STACK_PREFERENCES.md`**, **`ANTI_PATTERNS.md`** — preferences that shape every choice
5. **`playbooks/`** — workflow recipes the user can invoke ("PB-1", "PB-2", etc.)
6. **`context/`** — the design rationale (read if uncertain about why something is the way it is)

## Repo layout

```
.
├── README.md                    ← you are here
├── SPEC.md                      ← what the workbench is
├── SNAPSHOT-BUILD.md            ← how to build the snapshot the first time
├── STARTPROMPT-SNAPSHOT.md      ← human-to-Devin prompt for snapshot-build session
├── STARTPROMPT-SESSION.md       ← human-to-Devin prompt for any normal session
│
├── LESSONS.md                   ← grows monotonically, never deleted
├── STYLE.md                     ← code style preferences
├── STACK_PREFERENCES.md         ← default tech choices
├── ANTI_PATTERNS.md             ← what to avoid
│
├── playbooks/
│   ├── PB-1-cross-ai-review.md
│   ├── PB-2-adapter-factory.md
│   ├── PB-3-visual-regression.md
│   ├── PB-4-self-improvement-sweep.md
│   ├── PB-5-long-running-observer.md
│   └── PB-6-bootstrap-project.md
│
├── scripts/
│   ├── three-ai-consensus.sh    ← cross-AI code review
│   ├── claude-review.sh         ← Claude reviewer wrapper
│   ├── codex-review.sh          ← Codex reviewer wrapper
│   ├── visual-diff.sh           ← Playwright + pixelmatch
│   ├── acu-track.sh             ← cost telemetry per task
│   ├── bootstrap-project.sh     ← scaffold new project from template
│   ├── self-improvement-experiment.sh ← sandboxed recursive-improvement lab
│   └── verify-snapshot.sh       ← run after snapshot build to verify all layers
│
├── templates/
│   ├── python-fastapi/          ← scaffold for new Python services
│   └── nextjs-shadcn/           ← scaffold for new frontend projects
│
├── experiments/
│   └── self-improvement-loop/   ← controlled 14-day self-improvement experiment
│
├── .git-templates/
│   └── hooks/
│       └── pre-commit           ← gitleaks + ruff + tests
│
└── context/
    ├── README.md                ← orientation for future Claude sessions
    └── 00-design-rationale.md   ← why workbench looks this way
```

## State at end of successful snapshot build

- Ubuntu 22.04 VM with all 9 layers installed (see SNAPSHOT-BUILD.md)
- This repo cloned at `~/workbench/`
- `LESSONS.md` exists but empty (filled across sessions)
- All scripts in `scripts/` working and on PATH
- `INSTALL_LOG.md` written and committed back here
- Snapshot saved as `compounding-workbench-v1.0`

## State across sessions (the compounding part)

Every session adds 1-5 lessons to `LESSONS.md` (committed back to this repo).
Every week, PB-4 reads `LESSONS.md` and proposes snapshot updates.
Approved updates rebuild snapshot as v1.1, v1.2, etc.

The vault repo for Larder is **separate**. This repo is for the workbench itself, not for vault items.

## Hard rules

- **No installing tools that aren't in `SPEC.md`.** Want a new tool? Edit SPEC, propose, get human approval.
- **No skipping LESSONS.md updates.** A session without a lesson is a wasted session.
- **No bypassing pre-commit hooks.** They catch secret leaks and lint failures.
- **No editing snapshot directly.** Edit this repo, rebuild snapshot from spec.

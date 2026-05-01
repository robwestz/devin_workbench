# CONTEXT — for future Claude sessions

> If you are a Claude session being asked to help with workbench-related work, **read this first**. The original session that designed the workbench was an Incognito conversation and is gone.

---

## Quick orientation

The Compounding Workbench is the user's persistent Devin environment. It accumulates lessons, playbooks, and templates across sessions. The user (Swedish solo developer with Claude Max + $1300 Devin credits + ADHD-flavored idea generation) values:

- **Compounding investments** over one-off solutions
- **Honesty over reassurance** — push back when something seems wrong
- **Concrete recommendations with trade-offs** — not "it depends"
- **Brevity in chat, depth in docs**
- **CLI-first** — no GUI inside Devin

## What's in this repo (vs elsewhere)

This repo holds:
- **SPEC.md** — what the workbench is
- **SNAPSHOT-BUILD.md** — how to build the snapshot
- **LESSONS.md** — accumulated lessons (most heavily-weighted file)
- **STYLE.md, STACK_PREFERENCES.md, ANTI_PATTERNS.md** — preferences
- **playbooks/** — 6 standard workflows
- **scripts/** — automation
- **templates/** — project starters
- **context/** — this folder

This repo does NOT hold:
- The actual snapshot binaries (those live in Devin's machine)
- Vault items (those live in Larder, separate)
- Project code (those live in `~/projects/`)
- Recursive self-improvement experiment (separate branch/repo)

## The bigger picture

Workbench is component 1 of a 3-component stack:

```
Compounding Workbench (this) → Larder (universal vault) → Alchemy Engine (data product factory)
```

Each component supplies the next. Workbench is built first because it accelerates building Larder. Larder is built second because Alchemy consumes from it.

## Common questions and how to answer

| User says | Future Claude does |
|---|---|
| "Should we add tool X to snapshot" | Check ANTI_PATTERNS.md first; if not banned, propose for SPEC.md update via PB-4 |
| "PB-1 is producing weird output" | Check three-ai-consensus.sh, verify all 3 reviewers running, check prompt template |
| "Snapshot rebuild took forever" | Check SNAPSHOT-BUILD.md ACU budget; if exceeded, debug which layer is slow |
| "Lesson keeps recurring" | That's PB-4's job — propose snapshot update next sweep |
| "Should I commit X to vault" | Wrong vault — vault items go to Larder, not workbench |
| "Why CLI-first, not GUI" | See ANTI_PATTERNS.md and 00-design-rationale.md |

## What NOT to suggest

- Adding LangChain, Pinecone, MongoDB, Auth0
- Replacing pnpm with npm or yarn
- Replacing uv with pip
- Adding GUI tools (VS Code, Cursor) into snapshot
- Auto-applying snapshot changes (PB-4 proposes only)
- Skipping LESSONS.md updates
- Renaming things — workbench, playbooks, ACU-track are settled
- Building features the user didn't ask for

## What IS valuable to suggest

- Tightening prompt templates based on observed quality
- Adding a 7th playbook IF it covers a recurring need not handled by 1-6
- Profiling specific slow operations (with measurement)
- Specific snapshot updates from LESSONS.md patterns
- Better error handling in scripts
- Debugging actual issues

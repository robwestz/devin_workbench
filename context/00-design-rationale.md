# 00 — Design Rationale

> Why the Compounding Workbench is the way it is.

---

## Why "compounding" matters

The user has lots of project ideas (ADHD-flavored generation). The bottleneck is not ideas — it's the cost of starting from zero each time. A workbench that gets *measurably better* over weeks/months means:

- Week 1: standard Ubuntu + a few tools = baseline productivity
- Week 4: 3-4 lessons applied as snapshot updates = small speedups
- Month 6: 30+ lessons compounded into snapshot = significant speedup
- Year 1: the workbench is unique to the user, hard to replicate, encodes their preferences

The compounding works only if **lessons → updates** loop closes weekly. PB-4 enforces that closure.

## Why CLI-first (not VS Code in Devin)

Gemini suggested running Cursor/VS Code inside Devin. Rejected because:

- GUI rendering over remote display = slow
- UI changes break automation
- Devin's edge is desktop access for things ONLY desktop solves (browser, screenshots, visual diff)
- CLI is faster, more reliable, more debuggable
- The user already has a great local IDE; replicating it in Devin = duplicate effort

The desktop is reserved for Playwright (PB-3 visual regression) and other genuinely visual tasks.

## Why three reviewers in PB-1 (not one or many)

Considered alternatives:
- **One reviewer (just Claude):** has bias, single point of failure
- **Two reviewers (Claude + Codex):** still hard to break ties
- **Three (Claude + Codex + ollama):** odd number → consensus is unambiguous
- **Five+:** marginal value, multiplied cost

Three is enough to:
- Detect bias (when one disagrees with others)
- Cheap (ollama is free, Claude/Codex are paid but bounded)
- Fast (parallel)

## Why ollama in the mix

ollama path is "free" (local compute) and serves three purposes:
1. Sanity check — if Claude and Codex agree but ollama wildly disagrees, something is up
2. Smoke test before paying for hosted models
3. Ground truth for "is this code at all coherent" without paying

If ollama is missing or broken, fall back to 2-of-2. Don't block on it.

## Why LESSONS.md as the source of truth

Considered alternatives:
- **A database:** overkill for solo use; harder to grep
- **JSON file:** harder to edit by hand; loses casual annotations
- **Multiple files (one per category):** easier to lose lessons across files
- **Markdown:** browseable in editor, grep-able, git-diffable, human-friendly

Markdown won. Format is rigid (`YYYY-MM-DD | tag | observation | mitigation`) so PB-4 can parse, but the rest is freeform.

## Why 6 playbooks (not 3, not 12)

Each playbook has overhead (file, script, prompt template, mental model). Six is the smallest set that covers the recurring high-value workflows:

- PB-1: code review (used most often)
- PB-2: adapter generation (Larder integration)
- PB-3: visual regression (Devin's unique edge)
- PB-4: self-improvement (the compounding mechanism)
- PB-5: long-running observer (Devin's unique edge)
- PB-6: bootstrap project (saves 30 min per project start)

Considered but rejected:
- "PB-7: deploy" — too project-specific; lives in CI
- "PB-8: refactor" — too vague; refactor is what reviewers do
- "PB-9: documentation" — happens via Claude in chat, not Devin

If a 7th playbook becomes needed, PB-4 will surface it.

## Why mise + uv + pnpm (instead of system Python/Node)

- **mise:** version-pinning per repo via `.mise.toml`; no conflicts between projects
- **uv:** 10-100x faster than pip; better dependency resolution; uses pyproject.toml natively
- **pnpm:** symlinked store saves disk space; faster than npm/yarn; strict by default (no phantom deps)

These three together = no "it works on my machine" issues across projects.

## Why no in-snapshot secrets

Two reasons:
1. **Snapshots are shared/forked:** if user has a teammate with Devin Pro, snapshot can be cloned; secrets must not propagate
2. **Snapshot updates are versioned:** old versions sit on disk; old secrets sitting there = security drift

Secrets per-session via env. CLAUDE Code reads `~/.claude/credentials.json` if mounted (Path 1) or `ANTHROPIC_API_KEY` from env (Path 2). Same flexibility as Larder build.

## Why pre-commit hooks via global git template

Versus per-project hook setup:
- Global = applies to every new repo automatically
- No "I forgot to install hooks" failures
- gitleaks always runs = no accidental secret commits

Per-project additions still possible — just append to `.git/hooks/pre-commit` after init.

## Why this repo separate from the snapshot

Three reasons:
1. **Updates don't require snapshot rebuild:** edit LESSONS.md, push, next session has it (no rebuild)
2. **Cross-machine sync:** if user runs Devin from multiple accounts, repo is the single source
3. **Reviewable history:** git log shows the workbench's evolution; snapshot binaries don't

## What I'd revisit (honest critiques)

- **PB-3 visual diff has tolerance numbers I half-guessed.** First production use will tune them.
- **PB-5 observer's auth-state handling is naive.** If user needs to observe behind login, expand.
- **No telemetry on which playbooks are used.** Could add ACU-track integration to count playbook invocations. PB-4 would benefit.
- **Templates are minimal.** If user repeatedly customizes them the same way, that's a candidate for richer templates.
- **No "delete lesson" command.** Lessons append-only is intentional, but archive-after-90-days needs a cleanup script that's not yet written.

These are observations for future Claude, not action items. Don't proactively fix unless user asks.

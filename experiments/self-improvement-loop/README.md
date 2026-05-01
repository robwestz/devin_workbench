# Self-Improvement Loop Experiment

> A controlled 14-day experiment for testing whether Devin can improve its own workbench from observed session friction.

This is **not PB-4 replacement**. PB-4 remains the safe baseline: read `LESSONS.md`, propose changes, wait for human approval. This experiment tests the more aggressive Gemini idea — recursive self-improvement — but constrains it to telemetry, journaled proposals, reversible shell helpers, and a kill switch.

## What is being tested

The question is not "can Devin become recursively smarter?" The useful question is narrower:

> Is there enough signal in Devin's own command/runtime friction to generate small workbench improvements that save time without creating hidden risk?

If yes, the best parts can graduate into PB-4. If no, the experiment still saves ACU by killing a seductive but low-signal idea early.

## Safety model

### Kill switch first

```bash
self-improvement-experiment kill
```

The kill switch:

- writes `~/workbench/self-improvement-lab/KILLED`
- disables experiment-managed shell helpers
- leaves telemetry and journal files intact for audit
- does not edit `SPEC.md`, `SNAPSHOT-BUILD.md`, or the snapshot

### Three risk tiers

| Tier | Allowed? | Examples | Apply mode |
|---|---:|---|---|
| Tier 0 — observe | Yes | command duration, exit code, repeated friction | automatic |
| Tier 1 — reversible shell helpers | Opt-in | aliases/functions in `~/.bashrc.d/90-self-improvement-lab.sh` | `apply-tier1` only |
| Tier 2 — repo proposals | Review only | playbook edits, script changes, README updates | PR |
| Tier 3 — snapshot/system changes | Blocked | apt installs, systemd, new tools, secrets | PB-4 proposal only |

No tier may bake secrets into snapshot or install tools outside `SPEC.md`.

## Files written at runtime

Runtime files are intentionally ignored by git:

```text
~/workbench/self-improvement-lab/
├── telemetry.jsonl
├── JOURNAL.md
├── PROPOSALS.md
├── generated/
│   └── tier1-helpers.sh
└── KILLED
```

Daily reading target: `JOURNAL.md`. If it stops updating or looks weird, kill the experiment.

## Commands

```bash
self-improvement-experiment start
self-improvement-experiment record "bootstrap workbench" -- bash ~/workbench/scripts/verify-snapshot.sh
self-improvement-experiment analyze
self-improvement-experiment propose
self-improvement-experiment apply-tier1
self-improvement-experiment status
self-improvement-experiment kill
```

## 14-day protocol

### Days 1-7: telemetry only

Use `record` around any repeated workbench operation. Do not apply helpers yet.

At day 7:

1. Read `JOURNAL.md`
2. Read `PROPOSALS.md`
3. Kill the experiment if the proposals feel noisy, obvious, or unsafe
4. Continue only if at least one proposal clearly saves repeated work

### Days 8-14: Tier 1 opt-in

Run `apply-tier1` if the day-7 review passes. This only writes reversible shell helpers. Tier 2 changes still require a PR. Tier 3 changes remain blocked.

At day 14, decide:

- graduate a specific helper/playbook change into PB-4
- extend the experiment for another 14 days
- kill and archive findings

## What this intentionally does not do

- It does not use GUI-in-GUI IDE automation.
- It does not start Devin-inside-Devin sessions.
- It does not run unattended snapshot rebuilds.
- It does not inspect browser cookies, secrets, or private credentials.
- It does not auto-edit `SPEC.md`, `SNAPSHOT-BUILD.md`, or project code.

## Why this is more interesting than desktop gimmicks

Desktop is valuable when it lets Devin verify reality: visual state, browser auth flows, long-running observation, screenshots, and other tools' outputs. But the self-improvement loop should stay CLI-first because it needs auditability more than visual novelty.

The meta move is not "Devin watches itself in a GUI." The meta move is:

1. Devin records where work actually slows down.
2. Devin writes a daily journal of friction.
3. Devin proposes only small reversible improvements.
4. Human review decides what graduates into the durable workbench.

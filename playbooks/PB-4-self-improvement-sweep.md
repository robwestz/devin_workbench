# PB-4 — Self-Improvement Sweep

> Read LESSONS.md, identify patterns worth fixing, propose snapshot updates.
>
> The compounding mechanism that makes the workbench grow more useful over time.

## Trigger

- Weekly cron (Sundays 03:00) — proposals only, never auto-apply
- Manual: User says "Run PB-4" / "Self-improvement sweep" / "Improve yourself"

## What it does

1. Read entire LESSONS.md
2. Group lessons by tag (`repeated:slow`, `repeated:fail`, `stuck:`, `improvement:`)
3. For each tag with 3+ entries: propose a snapshot or playbook change
4. Write proposals to `IMPROVEMENT_PROPOSAL.md` in workbench repo
5. Commit + push (proposal only, never auto-apply)

## Output

```markdown
# IMPROVEMENT_PROPOSAL — 2026-04-30

## Repeated patterns analyzed
- 47 lessons in LESSONS.md
- 12 tagged `repeated:slow`
- 8 tagged `repeated:fail`
- 5 tagged `stuck:`
- 3 tagged `improvement:`

## Proposal 1: Add `gh` CLI to snapshot

**Evidence:** 4 lessons mention manually composing `git push` + browser-opening for PRs.

**Proposed change:** Add to `SNAPSHOT-BUILD.md` Layer 0:
```bash
sudo apt install -y gh
```

**Estimated impact:** ~1 minute saved per PR creation. Devin opens 5+ PRs per week.

**Risk:** Low. gh is well-maintained and stable.

**Approval needed:** Yes — this is a SPEC change.

---

## Proposal 2: New playbook PB-7 — "deploy preview"

**Evidence:** 3 lessons describe similar deploy-and-verify-preview workflows.

**Proposed change:** Add `playbooks/PB-7-deploy-preview.md` that combines:
- Vercel/Fly preview deploy
- PB-3 visual regression vs main
- Sanity-check console errors

**Risk:** Medium — new playbook means new surface area. May overlap with manual workflow.

**Approval needed:** Yes — propose, not implement.

---

## Proposal 3: Update prompt template for PB-1

**Evidence:** 5 lessons note PB-1 reviewers sometimes give vague feedback.

**Proposed change:** Tighten reviewer prompt to require specific line numbers in critical/suggested items.

**Risk:** Low — prompts are versioned, easy to revert.

**Approval needed:** Yes (prompt is in `scripts/three-ai-consensus.sh`).

---

## Recommendation

Apply proposal 1 (lowest risk, highest immediate value).
Discuss proposal 2 (overlap concern with manual workflows).
Apply proposal 3 with A/B test (compare output quality before/after).

ACU spent on this sweep: 1.8
```

## What PB-4 NEVER does

- Auto-apply snapshot changes
- Edit SPEC.md without approval
- Install tools
- Modify scripts
- Delete lessons (lessons are append-only)

PB-4 produces proposals. The user approves. The user (or Devin in a separate session, with explicit instruction) applies.

## When to run

- Weekly is the default cadence
- Manually if you've had a productive week with many lessons
- Skip if LESSONS.md grew <5 entries since last sweep

## When NOT to run

- During Phase 1 of any active build (focus on the build, not introspection)
- Same week as a snapshot rebuild (let new state settle first)
- If LESSONS.md is empty (nothing to analyze)

## Why this is "compounding"

Each session adds lessons → PB-4 surfaces patterns → snapshot/playbook updates → next sessions are faster → fewer lessons of same kind, more lessons of new kinds → richer signal → better proposals.

Without PB-4, lessons accumulate forever and no one acts on them. With PB-4, you have an automatic prioritization queue.

The compounding is **slow with intent**. PB-4 runs weekly, not hourly. Approval is human, not automatic. This is a feature.

## Cost

~1-2 ACU per sweep. LLM tokens: ~$0.10. Worth running weekly indefinitely.

## Safety

- All proposals committed before any action taken
- Diff between v1.x snapshots is auditable
- LESSONS.md never deleted, only archived after 90 days
- IMPROVEMENT_PROPOSAL.md keeps history (each sweep appends section, doesn't overwrite)

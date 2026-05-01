# PB-1 — Cross-AI Code Review

> Three AI reviewers, one consensus. Catch what one model misses.

## Trigger

User says: "Run PB-1 on this PR" / "Review with the panel" / "Three-AI review"

Or: Devin auto-triggers when committing >30 LOC of new code.

## What it does

Runs `~/workbench/scripts/three-ai-consensus.sh` against a git diff or branch:

1. Generate diff: `git diff origin/main...HEAD > /tmp/diff.patch`
2. Send diff to three reviewers in parallel:
   - **Claude Code (Sonnet)** — primary, deep reasoning
   - **Codex CLI** — second opinion, different training
   - **Local ollama (qwen2.5-coder:7b)** — smoke check, free, fast
3. Each returns structured JSON: `{ critical: [], suggested: [], nitpick: [] }`
4. Devin merges:
   - **Consensus** = issue raised by 2+ reviewers → likely real
   - **Divergence** = only 1 reviewer raised → flag for human attention

## Output format

```
=== PB-1 Review Summary ===

CONSENSUS (3/3 agreed): 2 issues
- [Critical] auth check missing in /api/users/{id}/delete
- [Suggested] error handling in upload_handler is too generic

CONSENSUS (2/3 agreed): 3 issues  
- [Suggested] consider rate limiting on /api/search
- [Suggested] N+1 query in get_user_with_posts
- [Nitpick] inconsistent naming: getUserById vs fetch_user

DIVERGENCE (1/3 raised): 4 issues — needs your eyes
- Claude says: refactor proposal for OrderService (complex)
- Codex says: test missing for edge case X
- ollama says: typo in comment line 47
- Codex says: deprecation warning for module Y

ACU spent: 1.2
Tokens used (Claude path): X | Codex: Y | ollama: 0 (local)

Recommended action:
- Fix consensus items autonomously? (y/n)
- Open divergence items for review.
```

## When to escalate concurrency or skip a reviewer

| Situation | Action |
|---|---|
| Diff <30 LOC | Skip, not worth ACU |
| Diff >2000 LOC | Split into sections, run sequentially |
| Claude path failing | Use Codex as primary, ollama for sanity |
| ollama missing/slow | Skip ollama, run 2/3 |
| Same reviewer disagrees with itself across files | Note in LESSONS.md, may indicate prompt drift |

## Cost calibration

| Diff size | Approx ACU |
|---|---|
| 30-100 LOC | 0.5 |
| 100-500 LOC | 1.5 |
| 500-2000 LOC | 3-5 |
| 2000+ LOC | Split first |

ollama path is free (local). Claude/Codex paths cost the LLM tokens — these are NOT counted in ACU but show up on subscription/API bills.

## Why this is the highest-leverage playbook

- One AI has bias. Three AIs that agree are usually right.
- Three AIs that disagree mark exactly the spots that need human attention.
- It's an attention filter, not a review tool. You read divergences, you trust consensus.
- Catches roughly 80% of issues I'd otherwise find in next-day review of my own code.

## Implementation

`~/workbench/scripts/three-ai-consensus.sh` — see scripts/ folder.

The reviewer prompt is the same across all three (consistency matters):

```
You are a senior engineer doing code review. The diff below is from a working 
branch about to merge to main.

Output ONLY valid JSON in this shape:
{
  "critical": ["..."],
  "suggested": ["..."],
  "nitpick": ["..."]
}

Critical = bugs, security issues, broken behavior
Suggested = real improvements (perf, clarity, correctness)
Nitpick = style preferences, taste calls

If you find nothing: return empty arrays. Do NOT pad.

Diff:
[paste]
```

Same prompt → comparable outputs → mergeable consensus.

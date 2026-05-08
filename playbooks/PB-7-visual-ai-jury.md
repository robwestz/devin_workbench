# PB-7 — Visual AI Jury

> Devin uses its desktop as a human QA surface, packages visual evidence, then asks multiple AI reviewers to critique the same user-facing flow.

## Trigger

- "Run visual AI jury on <url>"
- "Use the desktop to test this app and get AI feedback"
- "Do a product/UX review with Claude/Codex/Gemini"
- "Create a QA packet for this flow"

## What it does

1. Define the target flow and acceptance criteria.
2. Open the app in the real browser when human-visible state matters.
3. Record the run when the flow is non-trivial.
4. Capture screenshots, console/network notes, and observed UX issues.
5. Generate a review packet with:
   - target URL
   - task goal
   - steps performed
   - expected behavior
   - actual observations
   - screenshots/recording paths
   - console/network notes
   - optional git diff or PR URL
6. Send the same packet to AI reviewers.
7. Classify feedback:
   - **consensus**: 2+ reviewers or clear browser evidence
   - **divergence**: one reviewer only, needs human attention
   - **discarded**: vague taste, unsupported, or contradicts evidence
8. Patch only consensus issues unless the user explicitly asks for broader product changes.
9. Rerun the same flow and attach proof to the PR.

## Why this is a gamechanger

Normal code review sees code. Visual AI Jury sees the product.

It catches:

- broken navigation
- confusing copy
- layout regressions
- auth/session bugs
- mobile viewport issues
- console errors
- network failures
- UI states that are technically correct but product-bad

The key shift: Devin is not just writing code. Devin is operating as a small product team loop: QA, reviewer, UX critic, and engineer.

## Desktop vs hosted compute

Treat Devin's desktop as the **control plane**:

- Browser and screenshots run where Devin can see them.
- Heavy tools can be hosted elsewhere.
- If OpenClaw or another agent needs more compute, run it remotely and let Devin operate it through Chrome.
- Prefer API/CLI integration when available; use GUI when the tool has no API or logged-in state matters.

## Required safety boundaries

- Never extract browser cookies, tokens, passwords, or session secrets.
- Never deploy to production without explicit approval.
- Never let hosted tools directly mutate a repo unless their diff is reviewed by Devin and committed through normal git flow.
- Never treat a single AI's aesthetic preference as a required fix.
- Keep recordings/screenshots as evidence, not as hidden state.

## When to use

- Before merging frontend or full-stack UI changes.
- When a feature "works" but may feel wrong.
- When the user asks for product/UX feedback, not just code review.
- When an app depends on a logged-in browser flow.
- Before demos, launches, or paid-user-facing changes.

## When not to use

- Pure backend changes with no visible behavior.
- Tiny copy or config changes where browser testing is overkill.
- Flows requiring unavailable credentials.
- Highly destructive admin flows unless the user provides a sandbox account.

## Minimal command flow

```bash
visual-ai-jury init --id <short-id> --url <url> --goal "<goal>"
visual-ai-jury note --id <short-id> --step "Opened dashboard" --observation "Console clean"
visual-ai-jury screenshot --id <short-id> --path /absolute/path/to/screenshot.png --label "Dashboard loaded"
visual-ai-jury console --id <short-id> --summary "No console errors"
visual-ai-jury packet --id <short-id>
```

Then send `~/workbench/visual-ai-jury/<id>/PACKET.md` to reviewers.

## Reviewer prompt contract

Each reviewer gets the same packet and must respond with JSON:

```json
{
  "critical": ["Bug, broken flow, security/privacy issue"],
  "ux": ["Concrete UX/product issue with evidence"],
  "suggested": ["Useful improvement, not mandatory"],
  "discard": ["Things intentionally not worth changing"]
}
```

Vague feedback is ignored. Feedback without a step, screenshot, or observable evidence is divergence, not consensus.

## Output

```markdown
# Visual AI Jury Summary

Target: https://preview.example.com
Goal: Verify onboarding flow
Recording: /path/to/recording.webm
Packet: ~/workbench/visual-ai-jury/onboarding/PACKET.md

## Browser evidence
- Signup works
- Console has one hydration warning
- Mobile step 3 button is below fold

## Consensus fixes
- Mobile CTA hidden below fold (Claude + browser evidence)
- Error copy says "undefined" on invalid invite (Codex + Gemini)

## Divergence
- Gemini wants stronger headline; no evidence this is blocking

## Action
- Fix consensus issues
- Rerun same flow
- Attach recording to PR
```

## Relationship to existing playbooks

- PB-1 reviews code diffs.
- PB-3 compares screenshots across versions.
- PB-5 watches for long-running failures.
- PB-7 packages a human-visible product flow and asks reviewers to judge the same evidence.

Use PB-7 when "does the product feel and behave right?" matters more than "does this diff look okay?"

# PB-5 — Long-Running Observer

> Devin sits and watches a process or URL for a condition. When triggered, captures state and acts.

## Trigger

User says: "Watch <X> for <Y>" / "Observer mode for <hours>" / "Run PB-5"

Examples:
- "Watch the deploy at https://staging.example.com — alert me when it shows '500'"
- "Observe my CI pipeline for the next 2 hours and root-cause any failures"
- "Watch /var/log/app.log for ERROR lines, capture context when they appear"

## What it does

1. Devin starts a tmux session that survives session timeouts
2. A polling script checks the condition every N seconds (configurable, default 30s)
3. On trigger:
   - Capture state snapshot (logs, screenshots, diagnostic output)
   - Write to `~/workbench/observers/<id>/event.log`
   - (Optional) Notify user via Slack webhook if configured
   - (Optional) Enter "incident mode" — root-cause analysis loop

## Setup

```bash
# Devin starts observer
~/workbench/scripts/observer.sh start \
  --id "deploy-staging" \
  --target "https://staging.example.com" \
  --condition "status_code=500" \
  --on-trigger "capture-and-notify" \
  --duration "4h" \
  --interval 30
```

## Conditions supported

| Condition spec | Meaning |
|---|---|
| `status_code=500` | URL returns specific HTTP code |
| `status_code!=200` | URL returns anything other than 200 |
| `text_contains="error"` | Response body contains string |
| `text_missing="success"` | Response body lacks string |
| `latency>5000` | Response slower than 5s |
| `process_exits` | Watched process terminates |
| `log_pattern=ERROR.*timeout` | Log file matches regex |
| `file_changed=/path/to/file` | File mtime updated |

## On-trigger actions

| Action | What happens |
|---|---|
| `notify` | Webhook to user (Slack, Discord, email — configured) |
| `capture` | Save state snapshot to `observers/<id>/<timestamp>/` |
| `capture-and-notify` | Both |
| `incident` | Capture + start RCA loop (Devin reads logs, traces, suggests fix) |
| `auto-fix` | Apply pre-defined fix script (use cautiously) |

## Output during observation

```
[2026-04-30 14:00:00] Observer "deploy-staging" started.
  Target: https://staging.example.com
  Condition: status_code=500
  Interval: 30s
  Duration: 4h

[14:00:00] Status 200 — OK
[14:00:30] Status 200 — OK
...
[14:23:30] Status 500 — TRIGGERED
  Capturing state to observers/deploy-staging/20260430-142330/
  Notifying user via Slack
  Continuing observation...

[14:24:00] Status 200 — recovered (was transient)
[14:24:30] Status 200 — OK
...
```

## When to use

- **Flaky deploys** — catch the bad-state moment, not just the crash report
- **CI debugging** — observe a flaky test fire 1 of 10 times, capture context when it does
- **Long-running migrations** — alert on completion or failure
- **API monitoring** — for APIs you depend on but don't own
- **Resource leaks** — watch memory/disk/connection counts over hours

## When NOT to use

- For things that already have monitoring (Datadog, Sentry, etc.) — use those
- For trivial one-shot checks — use `curl` + `&&`
- For >24h observations — Devin sessions have limits; use external monitoring
- For high-frequency polling (<5s) — wasteful; consider WebSockets/SSE if API supports

## Cost

ACU per observation hour: ~0.5 (mostly idle, occasional poll).

For 4-hour observation: ~2 ACU. For overnight 12-hour observation: ~6 ACU.

Cap observation duration unless you have a clear stop condition. PB-5 will not run >24h without explicit re-confirmation.

## Why this is uniquely Devin's

Claude in chat can't run for 4 hours. Codex CLI can but doesn't have a desktop for screenshots. Devin has both: persistent VM + browser + clock.

This is exactly what Devin's edge looks like — long, low-attention work that keeps a finger on a pulse.

## Implementation

`~/workbench/scripts/observer.sh` — see scripts/.

Observers register in `~/workbench/observers/registry.json` so multiple can run concurrently and survive across sessions.

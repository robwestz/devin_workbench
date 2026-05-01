# STARTPROMPT-SESSION.md

> Use this prompt at the start of any normal Devin session (after snapshot is built).
>
> This is a template — customize the bracketed sections per session.

---

```
Session start.

Snapshot: compounding-workbench-v1.0 (or higher if updated)
Workbench repo: ~/workbench/ (auto-cloned by snapshot)

Standard pre-work:
1. cd ~/workbench && git pull
2. Read LESSONS.md (top 10 most recent)
3. Skim STYLE.md and STACK_PREFERENCES.md as reminder

Today's task:
[DESCRIBE TASK HERE]

Relevant playbooks (if any):
[OPTIONAL: e.g., "Run PB-1 on the resulting code"]

Constraints:
- ACU cap for this session: [N]
- Stop-and-ask threshold: [N - 5]

End-of-session protocol:
1. Append 1-3 lessons to ~/workbench/LESSONS.md
2. Run `acu-track --summary` and include in completion report
3. Commit LESSONS.md and any other workbench changes
4. Push

Begin.
```

---

## Worked example: bootstrapping a new project

```
Session start.

Snapshot: compounding-workbench-v1.0
Workbench: ~/workbench/

Pre-work:
1. cd ~/workbench && git pull
2. Read LESSONS.md (top 10)

Today's task:
Bootstrap a new Python FastAPI project called "weather-aggregator".
Use the python-fastapi template.
Wire it to consume `larder/api/open-meteo` from my Larder vault.
Initial endpoint: GET /forecast?city=<name>
Use Pydantic for request/response.

Run PB-6 (bootstrap project), then PB-1 (cross-AI review) on the result.

Constraints:
- ACU cap: 25
- Stop-and-ask: 20

End-of-session: lessons + acu-track summary + push.

Begin.
```

---

## Worked example: visual regression check

```
Session start.

Snapshot: compounding-workbench-v1.0

Pre-work: standard

Today's task:
Run PB-3 (visual regression) on https://staging.myproject.com 
vs https://myproject.com.

Capture diffs, post any meaningful regressions.
ACU cap: 8.

End-of-session: lessons + summary.

Begin.
```

---

## Worked example: weekly self-improvement sweep

```
Session start.

Snapshot: compounding-workbench-v1.0

Today's task:
Run PB-4 (self-improvement sweep).

Read the last 7 days of LESSONS.md. Identify any "repeated:" tagged 
lessons (problems that occurred 3+ times). Propose snapshot updates 
or new playbooks. Write proposals to IMPROVEMENT_PROPOSAL.md and 
commit. DO NOT apply changes — that's my decision.

ACU cap: 10.

Begin.
```

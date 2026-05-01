# STARTPROMPT-SNAPSHOT.md

> Paste this to Devin **once**, in the snapshot-build session, when you're configuring your Golden Snapshot for the first time.
>
> After this run completes successfully, you save the VM as "compounding-workbench-v1.0" in Devin's machine settings.

---

```
You are configuring a Golden Snapshot called "compounding-workbench-v1.0" for 
my Devin account. This is a one-time build session.

Source of truth: this repo (cloned at ~/workbench/).

Read order:
  1. README.md             — orientation
  2. SPEC.md               — what the workbench is and includes
  3. SNAPSHOT-BUILD.md     — layered installation guide (the actual work)

Build process:

1. Clone this repo to ~/workbench/.
2. Read SPEC.md to understand what you're building.
3. Read SNAPSHOT-BUILD.md fully BEFORE running any install commands.
4. Build Layers 0–9 in order. Verify each before next.
5. After Layer 9: run scripts/verify-snapshot.sh and capture output to 
   INSTALL_LOG.md.
6. Commit INSTALL_LOG.md back to this repo.
7. Notify me: "Snapshot v1.0-base ready. <X>/<Y> checks passed."

Optional tools (ask me before installing):
- 1Password CLI (only if I use 1Password — I'll tell you)
- Any layer with "(optional)" annotation in SPEC.md

Constraints:
- DO NOT bake API keys into the snapshot. They come per-session via env.
- DO NOT install anything not in this spec. If you find a layer can't 
  install, log it in INSTALL_LOG.md and continue; flag at end.
- Each layer must be idempotent (re-runnable without breaking).
- For each install command, capture stdout/stderr to INSTALL_LOG.md.
- If an install takes >5 min, log it as a candidate for pre-warm caching.

ACU budget: ~50 ACU. If you cross 60, STOP and post status.

End state: an Ubuntu 22.04 VM where every tool listed in SPEC.md works at 
the CLI without further setup. LESSONS.md exists but is empty (you'll start 
writing to it after first real session, not this one).

If anything is ambiguous in the spec, do NOT improvise. Ask me.

Begin.
```

---

## What you do after Devin reports success

1. Open Devin's machine settings → Save VM state
2. Name the snapshot: `compounding-workbench-v1.0`
3. Set as default snapshot for new sessions
4. (Optional) Create a shortcut on Devin's homepage: snapshot + STARTPROMPT-SESSION.md as playbook

From this point on, every new Devin session inherits this snapshot. You'll use `STARTPROMPT-SESSION.md` for normal sessions, not this snapshot-build prompt.

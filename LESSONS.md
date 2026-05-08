# LESSONS

> Vault-level lessons accumulated across sessions. Devin appends 1-5 entries per session.
>
> **Format:** `YYYY-MM-DD | tag | observation | mitigation`
>
> **Tags:**
> - `repeated:slow` — same operation took >2s, multiple times → candidate for caching/aliasing
> - `repeated:fail` — same command failed multiple times → candidate for tool addition
> - `stuck:` — agent paused or got confused
> - `surprise:` — something didn't work as expected; document for future
> - `improvement:` — successful workaround worth keeping

---

## Active

2026-05-01 | improvement:setup | PATH-linked workbench scripts must have executable bits in git, otherwise symlinks exist but direct commands fail | Keep `scripts/*.sh` and `.git-templates/hooks/pre-commit` mode 100755; verify with direct command invocation after linking
2026-05-08 | improvement:desktop | Devin's highest-leverage desktop use is as a control plane for visual QA and hosted AI/tool orchestration, not as a GUI IDE or local compute box | Use PB-7 to package browser evidence, console/network notes, recordings, and reviewer prompts before patching product-facing issues
2026-05-08 | surprise:review | PB-1 depends on reviewer CLIs being present; when `claude`, `codex`, or `ollama` are missing, consensus output can report tool absence instead of actionable code findings | Treat missing reviewer CLIs as environment readiness signals, not code-review findings; verify reviewer availability before trusting PB-1 output

---

## Archived (>90 days old or superseded)

(empty)

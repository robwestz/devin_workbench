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

---

## Archived (>90 days old or superseded)

(empty)

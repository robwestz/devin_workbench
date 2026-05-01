# PB-6 — Bootstrap Project

> Scaffold a new project from blueprint or template, including Git, dependencies, and Larder integration.

## Trigger

User says: "Bootstrap project <name>" / "Create new project: <description>" / "Start <name> from <blueprint>"

## What it does

1. Read blueprint (if provided) or ask clarifying questions about project type
2. Pick template from `~/workbench/templates/` (python-fastapi or nextjs-shadcn currently)
3. Create `~/projects/<name>/` from template
4. Initialize Git, hook to GitHub if user has gh CLI configured
5. Wire Larder dependencies if applicable
6. Set up `.envrc` for direnv
7. Run smoke tests to verify scaffold works
8. Commit initial state, push to GitHub
9. Run PB-1 cross-AI review on the scaffold itself

## Steps

```bash
~/workbench/scripts/bootstrap-project.sh <name> [--template <type>] [--blueprint <path>]
```

The script:

1. **Validate name:** lowercase, kebab-case, not already in `~/projects/`
2. **Choose template:**
   - If `--template` flag: use that
   - Else if blueprint exists: parse for stack hint, pick matching template
   - Else: ask user (single_select between python-fastapi / nextjs-shadcn / mixed)
3. **Copy template:**
   ```bash
   cp -r ~/workbench/templates/<chosen>/ ~/projects/<name>/
   cd ~/projects/<name>/
   ```
4. **Customize:**
   - Replace `{{PROJECT_NAME}}` placeholders in template files
   - Update `pyproject.toml` / `package.json` with project name
5. **Init Git + GitHub:**
   ```bash
   git init
   git add -A
   git commit -m "chore: initial scaffold from <template>"
   gh repo create <name> --private --source . --push
   ```
6. **Wire Larder if applicable:** if blueprint mentions API integration, prompt user to `larder use <id>` for relevant items
7. **Smoke test:**
   - Python: `uv pip install -e . && pytest`
   - Node: `pnpm install && pnpm test`
8. **PB-1 review** on the scaffold to confirm clean state

## Templates available

### `python-fastapi/`

Minimal FastAPI service:
- pyproject.toml with FastAPI + Pydantic + httpx + pytest pinned
- src/<name>/main.py with health endpoint
- src/<name>/api.py with example router
- src/<name>/models.py with Pydantic example
- tests/test_health.py
- .envrc template
- Dockerfile (for production)
- README.md template

### `nextjs-shadcn/`

Next.js 15 + Tailwind + shadcn/ui starter:
- package.json with Next 15 + React 19 + Tailwind + shadcn pinned
- app/layout.tsx, app/page.tsx
- components/ui/ with starter shadcn components
- lib/utils.ts (cn helper)
- next.config.js with strict TS
- .envrc template
- README.md template

Both templates inherit from STYLE.md and STACK_PREFERENCES.md.

## Output

```
=== PB-6: Bootstrap Project ===

Project: weather-aggregator
Template: python-fastapi
Location: ~/projects/weather-aggregator/
GitHub: github.com/<user>/weather-aggregator (private, pushed)

Scaffold:
  pyproject.toml        ✓
  src/weather_aggregator/  ✓
  tests/                ✓
  .envrc                ✓
  README.md             ✓

Smoke test: pytest tests/  → ✓ (1 passed in 0.4s)

Larder integrations applied:
  - larder use api/open-meteo  ✓
  - larder use api/nominatim   ✓ (for geocoding)

PB-1 cross-AI review: ✓ consensus clean, 0 critical, 0 suggested

Next steps:
- cd ~/projects/weather-aggregator
- direnv allow
- Open in editor and start building

ACU: 2.4
```

## When to use vs manual scaffold

| Situation | Use PB-6 |
|---|---|
| Brand new project | Yes |
| Continuation of existing project | No (just `cd` there) |
| Template doesn't fit | Manually scaffold, but contribute template if pattern repeats |
| Quick spike (<1h work) | Maybe overkill; just `mkdir` |
| Anything that'll see a 2nd commit | Yes, structure matters |

## Cost

~2 ACU + LLM costs from PB-1 review. Worth it for any non-throwaway project.

## Caveat: blueprint integration

If blueprint comes from `/200k-blueprint` or similar long-form architecture doc, PB-6 reads it but doesn't try to build from it — that's a different scope. PB-6 just scaffolds the empty shell with the right tooling. The actual building happens in subsequent sessions.

## Why this matters

The first 30 minutes of a new project are usually the lowest-value 30 minutes (deciding tooling, setting up repo, getting tests to run). PB-6 turns those 30 minutes into 3 minutes. Across 20 projects per year: ~9 hours saved per year on the same tedium.

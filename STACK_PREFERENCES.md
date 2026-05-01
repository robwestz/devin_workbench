# STACK_PREFERENCES

> Default tech choices. Override only with stated reason.

## Backend

- **API framework:** FastAPI + Pydantic
- **DB primary:** Postgres with JSONB
- **DB local/small:** SQLite
- **DB analytics:** DuckDB
- **Cache:** Redis
- **Vector store:** Qdrant locally; Turbopuffer in production
- **Task queue:** arq or Celery (arq if simple, Celery if complex routing)

## Frontend

- **Framework:** Next.js 15 + Tailwind + shadcn/ui
- **Type-safe API:** tRPC if frontend and backend share repo, else OpenAPI client gen
- **Forms:** react-hook-form + zod
- **State:** zustand for client state, TanStack Query for server state
- **Animation:** Framer Motion for UI animation, only if needed

## Hosting

- **Frontend:** Vercel
- **Backend:** Fly.io or Railway (Fly for production scale, Railway for prototyping)
- **DB:** Neon (Postgres) or Turso (SQLite-edge)
- **NEVER:** Heroku (deprecated), Vercel for backend (cold starts kill agent loops)

## Auth

- **Default:** Clerk (full-featured, low maintenance)
- **Alternative:** NextAuth (if Clerk too expensive or self-host required)
- **NEVER:** Auth0 (overpriced, complex)

## LLM stack

- **Routing:** always via LiteLLM
- **Structured output:** instructor
- **Code review:** Claude Code (Sonnet) primary; Codex CLI for second-opinion
- **Local model:** qwen2.5-coder:7b via ollama for quick questions / smoke tests
- **Embeddings:** local first (all-MiniLM via ollama), hosted only if quality requires
- **NEVER:** Hardcoded model names — always env or config

## Testing

- **Python:** pytest (+ hypothesis for property-based)
- **TS:** vitest
- **E2E:** playwright
- **Visual:** pixelmatch + reg-cli (PB-3)

## CI

- **Default:** GitHub Actions
- **For Larder/Workbench-managed projects:** scripts in `~/workbench/scripts/` run pre-commit; CI is for external validation, not local quality

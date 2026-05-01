# ANTI-PATTERNS

> Things to avoid without discussion. If you (Devin) feel a strong urge to use one of these, that's a signal something is wrong with the design — escalate to me before proceeding.

## Frameworks / Libraries

- **LangChain** — too complex for what it gives, churning API, fragile in production
- **LlamaIndex** — same reasons as LangChain, slightly less so but still
- **Pinecone** — Qdrant local + Turbopuffer prod cover all use cases at lower cost
- **Auth0** — overpriced, complex; Clerk does it better, NextAuth does it cheaper
- **Heroku** — deprecated for new work
- **MongoDB** for new projects — Postgres + JSONB is better in every dimension I've cared about
- **GraphQL by default** — REST + tRPC is simpler and sufficient

## Code patterns

- **`from X import *`** — implicit dependencies, hard to refactor
- **Hardcoded model names** in LLM calls — always env or config
- **`requests` library** — use `httpx` (async support, modern API)
- **`npm`** — use `pnpm`
- **`yarn`** — use `pnpm`
- **`pip` directly** — use `uv pip`
- **`python setup.py`** — use `pyproject.toml` and `uv`
- **Optimization before profiling** — measure first
- **"Optimization" as PR description** without numbers showing improvement

## Process patterns

- **Writing tests after a feature is done** — at least one test goes first
- **Catching `Exception` to "be safe"** — catch specifically what you handle
- **Massive `main.py` files** (500+ lines) — break into modules early
- **Comments that repeat code** — comments explain WHY
- **Premature abstraction** — three concrete uses before extracting

## LLM patterns

- **Chatbots when a tool would do** — if it's a structured task, expose it as a tool
- **Retry without backoff** — exponential backoff with jitter, always
- **Prompt without provenance** — log every prompt + model + version
- **Mock-only LLM tests** — at least one integration test against real API in CI

## Workbench-specific

- **Installing tools not in SPEC.md** — edit SPEC, propose, get approval, then install
- **Skipping LESSONS.md updates** — silent rotting of compounding effect
- **Bypassing pre-commit hooks** — they catch real problems
- **Editing snapshot directly** — edit this repo, rebuild snapshot from spec
- **Baking secrets into snapshot** — env per-session, always

## Project planning

- **"Refactor everything"** as a task — break into specific refactors with measurable improvement
- **"Add tests"** as a task — be specific about what behavior is being tested
- **Adding features the user didn't ask for** — even if they "would be nice"
- **Renaming things mid-project** — settle naming early, stick with it

## When you find yourself wanting to do one of these

The right action is **stop and ask**, not "this case is special". The list exists because every item has cost me time or money before. If you have a strong reason a specific case is different, write it up first; I'll review.

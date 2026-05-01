# STYLE

> Code style preferences. Devin should default to these unless project-specific reasons override.

## Python

- Type hints everywhere. mypy strict.
- Pydantic for all external data, dataclass for internal.
- `loguru` instead of stdlib logging.
- No relative imports outside the same package.
- Tests: pytest. Property-based: hypothesis.
- Async: prefer `asyncio` + `httpx` over `requests`.
- Use `uv` instead of pip directly. Use `uv tool install` for CLI tools.
- Modern syntax: `list[str]` not `List[str]`, `str | None` not `Optional[str]`.
- f-strings, no `.format()`.

## TypeScript / React

- TS strict mode.
- Server Components by default in Next.js.
- shadcn/ui over MUI, Chakra, Antd.
- Tailwind, no separate CSS files.
- Vitest, not Jest.
- pnpm, not npm.
- No barrel files (index.ts re-exports) unless explicitly requested.

## Git

- Conventional commits: feat / fix / chore / refactor / docs / test
- One thing per commit
- Squash on merge
- Branch names: `feat/<short-desc>`, `fix/<short-desc>`

## Files

- Python: `snake_case.py`
- TypeScript components: `PascalCase.tsx`
- Other TS: `kebab-case.ts`
- README.md in every package root
- No `.gitignore` exceptions for IDE config (use `~/.gitignore_global`)

## Comments

- Comments explain WHY, not WHAT
- TODO comments include date and initials: `# TODO(2026-04, devin): explain`
- Avoid commenting out code — delete and use git history

## Error handling

- Don't catch exceptions you can't handle
- When you do catch, be specific: `except FileNotFoundError`, not `except Exception`
- Log errors with context, don't just re-raise silently
- For LLM/agent code: structured failures with reason codes, not stack traces in prod

# {{PROJECT_NAME}}

Bootstrapped from `~/workbench/templates/python-fastapi`.

## Setup

```bash
cd {{PROJECT_NAME}}
direnv allow
uv pip install -e ".[dev]"
```

## Development

```bash
# Run server
python -m {{PROJECT_NAME_SNAKE}}.main

# Tests
pytest

# Lint + type check
ruff check src/ tests/
mypy src/
```

## Larder integration

```bash
# See available adapters
larder list --cat api

# Add a dependency from Larder
larder use api/<name>
```

## Structure

```
src/{{PROJECT_NAME_SNAKE}}/
├── main.py        # FastAPI app + uvicorn entry
├── api.py         # Routers
└── __init__.py
tests/
└── test_smoke.py
```

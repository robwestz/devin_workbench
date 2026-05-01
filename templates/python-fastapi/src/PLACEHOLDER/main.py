"""{{PROJECT_NAME}} — main entry point."""

from fastapi import FastAPI
from loguru import logger

from {{PROJECT_NAME_SNAKE}}.api import router

app = FastAPI(
    title="{{PROJECT_NAME}}",
    version="0.1.0",
)

app.include_router(router)


@app.get("/health")
async def health() -> dict[str, str]:
    """Health check endpoint."""
    return {"status": "ok"}


@logger.catch
def main() -> None:
    """CLI entry point."""
    import uvicorn

    uvicorn.run(app, host="0.0.0.0", port=8000)


if __name__ == "__main__":
    main()

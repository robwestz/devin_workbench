"""API router — example endpoint."""

from fastapi import APIRouter
from pydantic import BaseModel

router = APIRouter(prefix="/api")


class EchoRequest(BaseModel):
    """Echo request payload."""

    message: str


class EchoResponse(BaseModel):
    """Echo response."""

    echoed: str


@router.post("/echo", response_model=EchoResponse)
async def echo(req: EchoRequest) -> EchoResponse:
    """Echo back the message."""
    return EchoResponse(echoed=req.message)

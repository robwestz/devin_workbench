"""Smoke tests."""

from fastapi.testclient import TestClient

from {{PROJECT_NAME_SNAKE}}.main import app

client = TestClient(app)


def test_health() -> None:
    """Health endpoint returns ok."""
    response = client.get("/health")
    assert response.status_code == 200
    assert response.json() == {"status": "ok"}


def test_echo() -> None:
    """Echo endpoint roundtrips."""
    response = client.post("/api/echo", json={"message": "hi"})
    assert response.status_code == 200
    assert response.json() == {"echoed": "hi"}

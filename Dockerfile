FROM python:3.12-slim

COPY --from=ghcr.io/astral-sh/uv:0.11.31 /uv /uvx /bin/

WORKDIR /portfolio

ENV UV_NO_DEV=1

COPY pyproject.toml uv.lock ./
RUN uv sync --locked --no-install-project

RUN useradd --create-home --uid 1000 app

COPY --chown=app:app . .
RUN uv sync --locked && chown -R app:app /portfolio/.venv

USER app

EXPOSE 5000

# The venv's gunicorn directly, rather than `uv run`: no environment
# revalidation at startup, and nothing needs write access to /portfolio.
CMD [".venv/bin/gunicorn", "--bind", "0.0.0.0:5000", "--workers", "4", "app:app"]

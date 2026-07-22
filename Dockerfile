FROM python:3.12-slim

COPY --from=ghcr.io/astral-sh/uv:0.11.31 /uv /uvx /bin/

WORKDIR /portfolio

ENV UV_NO_DEV=1

COPY pyproject.toml uv.lock ./
RUN uv sync --locked --no-install-project

COPY . .
RUN uv sync --locked

EXPOSE 5000

CMD ["uv", "run", "gunicorn", "--bind", "0.0.0.0:5000", "--workers", "4", "app:app"]

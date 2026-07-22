#!/usr/bin/env bash
set -euo pipefail

PROJECT_DIR="/srv/portfolio"
PROJECT_USER="portfolio"
SITE_URL="https://tomasortin.duckdns.org/"

COMPOSE="docker compose -f docker-compose.yml --profile prod"

cd "$PROJECT_DIR"

sudo -u "$PROJECT_USER" -- git fetch --prune
sudo -u "$PROJECT_USER" -- git reset --hard origin/main
sudo -u "$PROJECT_USER" -- git clean -fdx --exclude=.env

$COMPOSE up -d --build --remove-orphans

wait_for() {
  local url=$1 name=$2
  for _ in $(seq 30); do
    if curl -fsS -o /dev/null "$url"; then
      echo "$name is serving"
      return 0
    fi
    sleep 2
  done
  echo "$name did not come up: $url" >&2
  return 1
}

if ! wait_for http://127.0.0.1:5000/ portfolio; then
  $COMPOSE logs --tail=50 portfolio >&2
  exit 1
fi

if ! wait_for "$SITE_URL" site; then
  $COMPOSE logs --tail=50 nginx >&2
  exit 1
fi

$COMPOSE ps

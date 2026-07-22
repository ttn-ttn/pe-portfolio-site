#!/usr/bin/env bash
set -euo pipefail

PROJECT_DIR="/srv/portfolio"
PROJECT_USER="portfolio"

cd "$PROJECT_DIR"

sudo -u "$PROJECT_USER" -- git fetch --prune
sudo -u "$PROJECT_USER" -- git reset --hard origin/main
sudo -u "$PROJECT_USER" -- git clean -fdx --exclude=.env

docker compose -f docker-compose.yml up -d --build --remove-orphans

for _ in $(seq 30); do
  if curl -fsS -o /dev/null http://127.0.0.1:5000/; then
    echo "portfolio is serving"
    docker compose -f docker-compose.yml ps
    exit 0
  fi
  sleep 2
done

echo "portfolio did not come up" >&2
docker compose -f docker-compose.yml logs --tail=50 portfolio >&2
exit 1

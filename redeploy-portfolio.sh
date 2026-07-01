#!/usr/bin/env bash
set -euo pipefail

PROJECT_DIR="/srv/portfolio"
PROJECT_USER="portfolio"

sudo -v
cd "$PROJECT_DIR"
sudo -u "$PROJECT_USER" -- git fetch && git reset origin/main --hard
sudo cp portfolio.service /etc/systemd/system/
sudo systemctl daemon-reload
sudo systemctl restart portfolio.service

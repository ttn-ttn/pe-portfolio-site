#!/usr/bin/env bash
set -euo pipefail

PROJECT_DIR="/srv/portfolio"
PROJECT_USER="portfolio"

sudo -v
cd "$PROJECT_DIR"
sudo -u "$PROJECT_USER" -- git fetch
sudo -u "$PROJECT_USER" -- git reset origin/main --hard
sudo chown -R "$PROJECT_USER:$PROJECT_USER" "$PROJECT_DIR"

if [[ ! -x "$PROJECT_DIR/.uv/bin/uv" ]]; then
  sudo -u "$PROJECT_USER" curl -LsSf https://astral.sh/uv/install.sh | \
    sudo -u "$PROJECT_USER" env HOME="$PROJECT_DIR" \
      UV_INSTALL_DIR="$PROJECT_DIR/.uv/bin" \
      UV_NO_MODIFY_PATH=1 \
      sh
fi

sudo -u "$PROJECT_USER" -- \
  env HOME="$PROJECT_DIR" \
      UV_DATA_HOME="$PROJECT_DIR/.uv/data" \
      UV_CACHE_HOME="$PROJECT_DIR/.uv/cache" \
      UV_PYTHON_INSTALL_DIR="$PROJECT_DIR/.uv/data/python" \
      TMPDIR="$PROJECT_DIR/.uv/tmp" \
      "$PROJECT_DIR/.uv/bin/uv" sync
sudo cp portfolio.service /etc/systemd/system/
sudo systemctl daemon-reload
sudo systemctl restart portfolio.service

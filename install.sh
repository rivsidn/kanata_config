#!/usr/bin/env bash
set -euo pipefail

cd "$(dirname "$0")"

install -d /home/yuchao/.config/kanata
install -m 0644 kanata.kbd /home/yuchao/.config/kanata/kanata.kbd
sudo install -m 0644 kanata.service /etc/systemd/system/kanata.service
sudo systemctl daemon-reload
sudo systemctl enable kanata.service
sudo systemctl restart kanata.service
systemctl status kanata.service --no-pager

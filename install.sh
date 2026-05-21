#!/usr/bin/env bash
set -euo pipefail

cd "$(dirname "$0")"

if [ "$(id -u)" -eq 0 ]; then
  echo "Run this script as your normal user, not with sudo." >&2
  exit 1
fi

kanata_bin="$(command -v kanata || true)"
if [ -z "$kanata_bin" ] && [ -x "$HOME/.cargo/bin/kanata" ]; then
  kanata_bin="$HOME/.cargo/bin/kanata"
fi
if [ -z "$kanata_bin" ]; then
  echo "kanata not found in PATH or $HOME/.cargo/bin/kanata" >&2
  exit 1
fi

kanata_dir="${XDG_CONFIG_HOME:-$HOME/.config}/kanata"
kanata_cfg="$kanata_dir/kanata.kbd"
service_tmp="$(mktemp --suffix=.service)"
trap 'rm -f "$service_tmp"' EXIT

install -d "$kanata_dir"
install -m 0644 kanata.kbd "$kanata_cfg"
kanata_bin_sed="$(printf '%s' "$kanata_bin" | sed 's/[&|]/\\&/g')"
kanata_cfg_sed="$(printf '%s' "$kanata_cfg" | sed 's/[&|]/\\&/g')"
sed \
  -e "s|@KANATA_BIN@|$kanata_bin_sed|g" \
  -e "s|@KANATA_CFG@|$kanata_cfg_sed|g" \
  kanata.service.temp > "$service_tmp"
systemd-analyze verify "$service_tmp"
sudo install -m 0644 "$service_tmp" /etc/systemd/system/kanata.service
sudo systemctl daemon-reload
sudo systemctl enable kanata.service
sudo systemctl restart kanata.service
systemctl status kanata.service --no-pager

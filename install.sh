#!/usr/bin/env bash
set -euo pipefail

force_private=0

usage() {
  cat <<'EOF'
Usage: ./install.sh [--force-private]

Options:
  --force-private  Overwrite an existing kanata.private.kbd.
  -h, --help       Show this help.
EOF
}

while [ "$#" -gt 0 ]; do
  case "$1" in
    --force-private)
      force_private=1
      ;;
    -h|--help)
      usage
      exit 0
      ;;
    *)
      echo "Unknown option: $1" >&2
      usage >&2
      exit 1
      ;;
  esac
  shift
done

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
kanata_private_src="kanata.private.kbd"
kanata_private_cfg="$kanata_dir/kanata.private.kbd"
service_tmp="$(mktemp --suffix=.service)"
trap 'rm -f "$service_tmp"' EXIT

install -d "$kanata_dir"
install -m 0644 kanata.kbd "$kanata_cfg"
if [ -f "$kanata_private_src" ] && { [ ! -e "$kanata_private_cfg" ] || [ "$force_private" -eq 1 ]; }; then
  install -m 0600 "$kanata_private_src" "$kanata_private_cfg"
fi
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

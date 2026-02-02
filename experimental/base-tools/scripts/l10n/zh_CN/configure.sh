#!/usr/bin/env bash
set -euo pipefail

SOURCE_DIR=$(dirname "$(readlink -f "${BASH_SOURCE[0]}")")
chmod +x "$SOURCE_DIR/"*.sh
# Configure APT source list by distro: Debian -> debian.sources; Ubuntu -> Tsinghua Ubuntu mirror
if [ -f /etc/os-release ]; then
  # shellcheck source=/dev/null
  . /etc/os-release
  case "${ID:-}" in
    debian)
      "$SOURCE_DIR/configure-deb-source.sh"
      ;;
    ubuntu)
      "$SOURCE_DIR/configure-ubuntu-source.sh"
      ;;
    *)
      echo "Skipping APT source config on $ID (not Debian/Ubuntu)."
      ;;
  esac
else
  echo "Skipping APT source config: /etc/os-release not found."
fi
# configure locale
"$SOURCE_DIR/configure-locale.sh"

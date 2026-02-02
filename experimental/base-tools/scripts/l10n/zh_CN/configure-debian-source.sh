#!/usr/bin/env bash
set -euo pipefail

# Replace /etc/apt/sources.list with USTC Debian mirror (for zh_CN)
# Usage: run as root; requires VERSION_CODENAME from /etc/os-release (e.g. bookworm)

TARGET=/etc/apt/sources.list
MIRROR="http://mirrors.tuna.tsinghua.edu.cn/debian"

if [ "$(id -u)" -ne 0 ]; then
  echo "This script must be run as root" >&2
  exit 1
fi

if [ -f /etc/os-release ]; then
  # shellcheck source=/dev/null
  . /etc/os-release
else
  echo "Cannot read /etc/os-release" >&2
  exit 1
fi

CODENAME="${VERSION_CODENAME:-}"
if [ -z "$CODENAME" ]; then
  echo "VERSION_CODENAME not set in /etc/os-release" >&2
  exit 1
fi

mkdir -p "$(dirname "$TARGET")"
if [ -f "$TARGET" ]; then
  ts=$(date -u +%Y%m%dT%H%M%SZ)
  backup="$TARGET.bak-$ts"
  echo "Backing up existing $TARGET -> $backup"
  cp -a "$TARGET" "$backup"
fi

cat > "$TARGET" << EOF
# 默认注释了源码仓库，如有需要可自行取消注释
deb ${MIRROR} ${CODENAME} main contrib non-free non-free-firmware
# deb-src ${MIRROR} ${CODENAME} main contrib non-free non-free-firmware
deb ${MIRROR} ${CODENAME}-updates main contrib non-free non-free-firmware
# deb-src ${MIRROR} ${CODENAME}-updates main contrib non-free non-free-firmware
EOF
chmod 644 "$TARGET"

echo "Done. Configured Debian APT sources (${CODENAME}) -> $TARGET"
cat "$TARGET" || true

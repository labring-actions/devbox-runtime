#!/usr/bin/env bash
set -euo pipefail

# Replace /etc/apt/sources.list with Tsinghua Ubuntu mirror (for zh_CN)
# Usage: run as root; requires VERSION_CODENAME from /etc/os-release (e.g. jammy, noble)

TARGET=/etc/apt/sources.list
MIRROR="http://mirrors.tuna.tsinghua.edu.cn/ubuntu"

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
deb [trusted=yes] ${MIRROR}/ ${CODENAME} main restricted universe multiverse
# deb-src ${MIRROR}/ ${CODENAME} main restricted universe multiverse
deb [trusted=yes] ${MIRROR}/ ${CODENAME}-updates main restricted universe multiverse
# deb-src ${MIRROR}/ ${CODENAME}-updates main restricted universe multiverse
deb [trusted=yes] ${MIRROR}/ ${CODENAME}-backports main restricted universe multiverse
# deb-src ${MIRROR}/ ${CODENAME}-backports main restricted universe multiverse
deb [trusted=yes] ${MIRROR}/ ${CODENAME}-security main restricted universe multiverse
# deb-src ${MIRROR}/ ${CODENAME}-security main restricted universe multiverse
EOF
chmod 644 "$TARGET"

echo "Done. Configured Ubuntu APT sources (${CODENAME}) -> $TARGET"
cat "$TARGET" || true

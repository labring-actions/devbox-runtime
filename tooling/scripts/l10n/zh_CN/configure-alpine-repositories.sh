#!/usr/bin/env bash
set -euo pipefail

TARGET=/etc/apk/repositories
MIRROR="https://mirrors.tuna.tsinghua.edu.cn/alpine"

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

VERSION="${VERSION_ID:-}"
if [ -z "$VERSION" ]; then
  echo "VERSION_ID not set in /etc/os-release" >&2
  exit 1
fi

MAJOR_MINOR="$(printf '%s\n' "$VERSION" | awk -F. '{ printf "%s.%s", $1, $2 }')"
BRANCH="v${MAJOR_MINOR}"

if [ -f "$TARGET" ]; then
  ts=$(date -u +%Y%m%dT%H%M%SZ)
  backup="$TARGET.bak-$ts"
  echo "Backing up existing $TARGET -> $backup"
  cp -a "$TARGET" "$backup"
fi

cat > "$TARGET" <<EOF
${MIRROR}/${BRANCH}/main
${MIRROR}/${BRANCH}/community
EOF
chmod 644 "$TARGET"

echo "Done. Configured Alpine APK repositories (${BRANCH}) -> $TARGET"
cat "$TARGET" || true

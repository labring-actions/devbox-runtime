#!/usr/bin/env bash
set -euo pipefail

# Replace /etc/apt/sources.list.d/debian.sources with the bundled debian.sources
# Usage: run as root (in image/container)

TARGET=/etc/apt/sources.list.d/debian.sources
SOURCE_DIR=$(dirname "$(readlink -f "${BASH_SOURCE[0]}")")
SOURCE_FILE="$SOURCE_DIR/debian.sources"

if [ "$(id -u)" -ne 0 ]; then
  echo "This script must be run as root" >&2
  exit 1
fi

if [ ! -f "$SOURCE_FILE" ]; then
  echo "Source file not found: $SOURCE_FILE" >&2
  exit 1
fi

mkdir -p "$(dirname "$TARGET")"

if [ -f "$TARGET" ]; then
  ts=$(date -u +%Y%m%dT%H%M%SZ)
  backup="$TARGET.bak-$ts"
  echo "Backing up existing $TARGET -> $backup"
  cp -a "$TARGET" "$backup"
fi

echo "Installing $SOURCE_FILE -> $TARGET"
cp -a "$SOURCE_FILE" "$TARGET"
chmod 644 "$TARGET"

echo "Done. Current contents of $TARGET:"
cat "$TARGET" || true
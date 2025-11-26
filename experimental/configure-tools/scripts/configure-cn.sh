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

echo "Refreshing apt lists"
if command -v apt-get >/dev/null 2>&1; then
  # Update keyring first if present in the image
  if [ -f /usr/share/keyrings/debian-archive-keyring.gpg ]; then
    apt-get update -y || true
  else
    # If no keyring installed, attempt to install keyring (best-effort)
    if apt-get --version >/dev/null 2>&1; then
      apt-get update -y || true
    fi
  fi
else
  echo "apt-get not found, skipping apt update"
fi

echo "Done. Current contents of $TARGET:"
cat "$TARGET" || true

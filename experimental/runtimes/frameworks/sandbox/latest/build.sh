#!/usr/bin/env bash
set -euo pipefail

DEFAULT_DEVBOX_USER=${DEFAULT_DEVBOX_USER:-devbox}

if ! id -u "$DEFAULT_DEVBOX_USER" &>/dev/null; then
  echo "User $DEFAULT_DEVBOX_USER does not exist"
  exit 1
fi

TARGET_DIR="/home/$DEFAULT_DEVBOX_USER/workspace"
mkdir -p "$TARGET_DIR"

chown -R "$DEFAULT_DEVBOX_USER:$DEFAULT_DEVBOX_USER" "$TARGET_DIR"

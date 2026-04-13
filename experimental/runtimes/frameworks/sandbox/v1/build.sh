#!/usr/bin/env bash
set -euo pipefail

DEFAULT_DEVBOX_USER=${DEFAULT_DEVBOX_USER:-devbox}
DEVBOX_HOME="$(getent passwd "$DEFAULT_DEVBOX_USER" | cut -d: -f6 || true)"

if [ -z "$DEVBOX_HOME" ]; then
  DEVBOX_HOME="/home/${DEFAULT_DEVBOX_USER}"
fi

if ! id -u "$DEFAULT_DEVBOX_USER" &>/dev/null; then
  echo "User $DEFAULT_DEVBOX_USER does not exist"
  exit 1
fi

TARGET_DIR="${CODEX_GATEWAY_CWD:-${DEVBOX_HOME}/workspace}"
mkdir -p "$TARGET_DIR"

chown -R "$DEFAULT_DEVBOX_USER:$DEFAULT_DEVBOX_USER" "$TARGET_DIR"

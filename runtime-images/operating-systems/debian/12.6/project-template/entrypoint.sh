#!/bin/bash
set -euo pipefail

if [ "$(id -u)" -eq 0 ] && [ "${DEVBOX_ENTRYPOINT_AS_DEVBOX:-1}" = "1" ] && id devbox >/dev/null 2>&1; then
    export DEVBOX_ENTRYPOINT_AS_DEVBOX=0
    SCRIPT_PATH=$(readlink -f "$0")
    exec runuser -u devbox -- bash "$SCRIPT_PATH" "$@"
fi

# Use busybox httpd to serve a simple "Hello, World!" page
PORT=${PORT:-8080}
PROJECT_DIR=${PROJECT_DIR:-/home/devbox/project}
ROOT_DIR="$PROJECT_DIR/www"
mkdir -p "$ROOT_DIR"

cat >"$ROOT_DIR/index.html" <<'HTML'
Hello, World!
HTML

echo "Starting HTTP server on port $PORT (serving $ROOT_DIR)"

if command -v busybox >/dev/null 2>&1; then
    exec busybox httpd -f -p "$PORT" -h "$ROOT_DIR"
fi

echo "No supported HTTP server found (busybox httpd)." >&2
exit 1

#!/bin/bash
set -euo pipefail

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
    # Common busybox httpd usage: -p <port> -h <directory>
    busybox httpd -p "$PORT" -h "$ROOT_DIR"
    rc=$?
    exit $rc
fi

echo "No supported HTTP server found (busybox httpd)." >&2
exit 1


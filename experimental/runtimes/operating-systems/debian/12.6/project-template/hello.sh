#!/bin/bash
set -euo pipefail

# Use mini-httpd as the primary server. If not available, fall back to busybox httpd
# or Python's http.server. The script `exec`s the server so the PID supervised by
# s6 is the HTTP server process itself.

PORT=${PORT:-8080}
PROJECT_DIR=${PROJECT_DIR:-/home/devbox/project}
ROOT_DIR="$PROJECT_DIR/www"
mkdir -p "$ROOT_DIR"

cat >"$ROOT_DIR/index.html" <<'HTML'
Hello, World!
HTML

echo "Starting HTTP server on port $PORT (serving $ROOT_DIR)"

if command -v mini_httpd >/dev/null 2>&1; then
    # Common mini-httpd usage: -p <port> -d <directory>
    exec mini_httpd -p "$PORT" -d "$ROOT_DIR"
    exit 0
fi

echo "No supported HTTP server found (mini-httpd)." >&2
exit 1
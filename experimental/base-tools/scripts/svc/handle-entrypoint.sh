#!/usr/env/bin bash
set -euo pipefail

PROJECT_DIR=${PROJECT_DIR:-/home/devbox/project}
DEFAULT_DEVBOX_USER=${DEFAULT_DEVBOX_USER:-devbox}

if [ ! -f "$PROJECT_DIR/entrypoint.sh" ]; then
  # No entrypoint.sh found; nothing to do
  echo "No entrypoint.sh found in project directory: $PROJECT_DIR" >&2
	# No child started; exit success
	exit 0
fi

cd "$PROJECT_DIR"
chmod +x ./entrypoint.sh
s6-setuidgid "$DEFAULT_DEVBOX_USER" /bin/bash ./entrypoint.sh "${DEVBOX_ENV:-development}" &
CHILD_PID=$!
if [ -n "${CHILD_PID:-}" ]; then
  cleanup() {
    # clean up entrypoint's child processes
    pkill -TERM -P "$CHILD_PID" 2>/dev/null || true
  }
  trap cleanup SIGTERM SIGINT
  # Wait for the child process and propagate its exit code
  wait "$CHILD_PID"
  rc=$?
  exit "$rc"
fi
exit 0

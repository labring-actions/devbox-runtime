#!/usr/bin/env bash
set -euo pipefail
# Source some common functions and variables
BASE_TOOLS_DIR=${BASE_TOOLS_DIR:-/opt/base-tools}
ROOT_DIR=$BASE_TOOLS_DIR/scripts/svc
source $ROOT_DIR/common.sh
# Setup s6 service for entrypoint.sh
S6_DIR=/etc/s6-overlay/s6-rc.d
mkdir -p "$S6_DIR"
# entrypoint oneshot referencing existing script
mkdir -p "$S6_DIR/entrypoint" "$S6_DIR/entrypoint/dependencies.d"
cp "$ROOT_DIR/handle-entrypoint.sh" "$S6_DIR/entrypoint/handle-entrypoint.sh"
# Create run first (idempotent overwrite)
cat >"$S6_DIR/entrypoint/run" <<'entrypoint'
#!/command/with-contenv bash
set -euo pipefail

PROJECT_DIR="/home/devbox/project"
DEFAULT_DEVBOX_USER=${DEFAULT_DEVBOX_USER:-devbox}

if [ -f "$PROJECT_DIR/entrypoint.sh" ]; then
	# Change to project directory before executing entrypoint.sh
	# This ensures relative paths in entrypoint.sh work correctly
	cd "$PROJECT_DIR"
	chmod +x ./entrypoint.sh
	# Pass DEVBOX_ENV as first argument to entrypoint.sh
	s6-setuidgid $DEFAULT_DEVBOX_USER ./entrypoint.sh "${DEVBOX_ENV:-development}" & 
	PPID=$!
	cleanup() {
	  pkill -TERM -P $PPID 2>/dev/null
	}
	if [ -n "$PPID" ]; then
	  trap cleanup SIGTERM SIGINT
	  # Wait for the child process and propagate its exit code
	  wait "$PPID"
	  rc=$?
	  exit "$rc"
	fi

	# No child started; exit success
	exit 0
fi

entrypoint
echo oneshot >"$S6_DIR/entrypoint/type"
echo '/etc/s6-overlay/s6-rc.d/entrypoint/run' >"$S6_DIR/entrypoint/up"
chmod 644 "$S6_DIR/entrypoint/up"


for svc in entrypoint; do
	: >"$S6_DIR/user/contents.d/$svc"
done

# Ensure s6 service scripts have correct permissions if they already exist (idempotent)
for f in \
    $S6_DIR/entrypoint/run; do
    [ -f "$f" ] && chmod 700 "$f" || true
done

echo "entrypoint ensured." >&2
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
# Create run first (idempotent overwrite)
cat >"$S6_DIR/entrypoint/run" <<'entrypoint'
#!/command/with-contenv bash
set -euo pipefail

PROJECT_DIR="/home/devbox/project"

if [ -f "$PROJECT_DIR/entrypoint.sh" ]; then
	# Change to project directory before executing entrypoint.sh
	# This ensures relative paths in entrypoint.sh work correctly
	cd "$PROJECT_DIR"
	# Pass DEVBOX_ENV as first argument to entrypoint.sh
	exec "$PROJECT_DIR/entrypoint.sh" "${DEVBOX_ENV:-development}"
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
#!/usr/bin/env bash
set -euo pipefail
# Source some common functions and variables
BASE_TOOLS_DIR=${BASE_TOOLS_DIR:-/opt/base-tools}
ROOT_DIR=$BASE_TOOLS_DIR/scripts/svc
STARTUP_SCRIPTS_DIR=${STARTUP_SCRIPTS_DIR:-/usr/start}
source $ROOT_DIR/common.sh
# Setup s6 service for startup.sh
S6_DIR=/etc/s6-overlay/s6-rc.d
mkdir -p "$S6_DIR"
# startup oneshot referencing existing script
mkdir -p "$S6_DIR/startup" "$S6_DIR/startup/dependencies.d"
cp "$ROOT_DIR/handle-startup.sh" "$S6_DIR/startup/handle-startup.sh"
# Copy default start up scripts to STARTUP_SCRIPTS_DIR
# These scripts should exit quickly to prevent delaying container startup
mkdir -p "$STARTUP_SCRIPTS_DIR"
shopt -s nullglob
startup_items=("$ROOT_DIR"/startup/*)
if [ ${#startup_items[@]} -gt 0 ]; then
    chmod +x "${startup_items[@]}"
    cp -r "${startup_items[@]}" "$STARTUP_SCRIPTS_DIR/"
fi
shopt -u nullglob
# Create run first (idempotent overwrite)
cat >"$S6_DIR/startup/run" <<'STARTUP'
#!/command/with-contenv bash
set -euo pipefail
SOURCE_DIR=$(dirname "$(readlink -f "${BASH_SOURCE[0]}")")
chmod +x "$SOURCE_DIR/handle-startup.sh"
"$SOURCE_DIR/handle-startup.sh"
STARTUP
echo oneshot >"$S6_DIR/startup/type"
echo '/etc/s6-overlay/s6-rc.d/startup/run' >"$S6_DIR/startup/up"
chmod 644 "$S6_DIR/startup/up"


for svc in startup; do
	: >"$S6_DIR/user/contents.d/$svc"
done

# Ensure s6 service scripts have correct permissions if they already exist (idempotent)
for f in \
    $S6_DIR/startup/run; do
    [ -f "$f" ] && chmod 700 "$f" || true
done

echo "startup ensured." >&2
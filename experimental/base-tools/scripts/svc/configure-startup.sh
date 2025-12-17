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
cp "$ROOT_DIR/handle-startup.sh" "$S6_DIR/entrypoint/handle-startup.sh"
# copy default start up scripts to STARTUP_SCRIPTS_DIR
# these scripts should exit quickly to prevent delaying container startup
mkdir -p "$STARTUP_SCRIPTS_DIR"
chmod +x "$ROOT_DIR/startup/"*
cp -r $ROOT_DIR/startup/* "$STARTUP_SCRIPTS_DIR/"
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
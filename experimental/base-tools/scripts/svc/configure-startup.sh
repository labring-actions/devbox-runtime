#!/usr/bin/env bash
set -euo pipefail
# Source some common functions and variables
BASE_TOOLS_DIR=${BASE_TOOLS_DIR:-/opt/base-tools}
ROOT_DIR=$BASE_TOOLS_DIR/scripts/svc
source $ROOT_DIR/common.sh
# Setup s6 service for startup.sh
S6_DIR=/etc/s6-overlay/s6-rc.d
mkdir -p "$S6_DIR"
# startup oneshot referencing existing script
mkdir -p "$S6_DIR/startup" "$S6_DIR/startup/dependencies.d"
# Create run first (idempotent overwrite)
cat >"$S6_DIR/startup/run" <<'STARTUP'
#!/usr/bin/env bash
set -euo pipefail

if [ -n "${SEALOS_DEVBOX_NAME:-}" ]; then
	echo "${SEALOS_DEVBOX_NAME}" > /etc/hostname
fi
mkdir -p /usr/start
if [ -n "${SEALOS_DEVBOX_POD_UID:-}" ]; then
	echo "${SEALOS_DEVBOX_POD_UID}" > /usr/start/pod_id
fi
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
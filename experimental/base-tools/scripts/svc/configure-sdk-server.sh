#!/usr/bin/env bash
set -euo pipefail

# Setup s6 service for devbox-sdk-server
S6_DIR=/etc/s6-overlay/s6-rc.d
SDK_SERVER=sdk-server
mkdir -p "$S6_DIR/$SDK_SERVER" "$S6_DIR/$SDK_SERVER/dependencies.d"

# Create run first
echo longrun >"$S6_DIR/$SDK_SERVER/type"
cat >"$S6_DIR/$SDK_SERVER/run" <<'sdk-server'
#!/command/with-contenv bash
set -euo pipefail
if [ -n "${DEVBOX_JWT_SECRET:-}" ] && [ "${DEVBOX_ENV:-}" != "production" ]; then
	echo "DEVBOX_JWT_SECRET exists and is non-empty AND DEVBOX_ENV is not production"
	# start the longrun devbox sdk server service.
	export HOME=/home/devbox
	exec s6-setuidgid devbox /usr/sbin/devbox-sdk-server --workspace-path=/home/devbox/project
else
	# custom exit code to indicate missing env var
    exit 101
fi
sdk-server
chmod 700 "$S6_DIR/$SDK_SERVER/run"

# Create finish script to handle specific exit codes
cat >"$S6_DIR/$SDK_SERVER/finish" <<'finish-sdk-server'
#!/usr/bin/env bash
EXIT_CODE=$1
if [ "$EXIT_CODE" = "101" ]; then
	echo "Devbox SDK Server stopped due to missing required environment variable DEVBOX_JWT_SECRET. Preventing s6 restart."
	# s6 docs: Exiting finish script with 125 tells s6 to stop managing the service.
	exit 125
else
	echo "Devbox SDK Server terminated unexpectedly (Exit Code: $EXIT_CODE), s6 will restart according to default policy."
	# Exit with 0 or 1 to allow s6 to continue its default restart cycle (usually restarts).
	exit 1
fi
finish-sdk-server
chmod 700 "$S6_DIR/$SDK_SERVER/finish"

: >"$S6_DIR/user/contents.d/$SDK_SERVER"

echo "devbox sdk server services ensured." >&2

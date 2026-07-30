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
if [ -z "${DEVBOX_JWT_SECRET:-}" ]; then
	# custom exit code to indicate missing required env var
	exit 101
fi

if [ "${DEVBOX_ENV:-}" = "production" ]; then
	# custom exit code to indicate sdk-server is disabled in production
	exit 102
fi

# Map optional env vars to sdk-server CLI flags.
# Prefer DEVBOX_SDK_* names; fall back to the binary's native env names.
sdk_server_args=(
	--token="$DEVBOX_JWT_SECRET"
	--workspace-path="${DEVBOX_SDK_WORKSPACE_PATH:-${WORKSPACE_PATH:-/home/devbox/project}}"
)
if [ -n "${DEVBOX_SDK_ADDR:-${ADDR:-}}" ]; then
	sdk_server_args+=(--addr="${DEVBOX_SDK_ADDR:-$ADDR}")
fi
if [ -n "${DEVBOX_SDK_MAX_FILE_SIZE:-${MAX_FILE_SIZE:-}}" ]; then
	sdk_server_args+=(--max-file-size="${DEVBOX_SDK_MAX_FILE_SIZE:-$MAX_FILE_SIZE}")
fi
if [ -n "${DEVBOX_SDK_MAX_CONCURRENT_READS:-${MAX_CONCURRENT_READS:-}}" ]; then
	sdk_server_args+=(--max-concurrent-reads="${DEVBOX_SDK_MAX_CONCURRENT_READS:-$MAX_CONCURRENT_READS}")
fi

if [ -n "${DEVBOX_SDK_RUN_AS_ROOT:-}" ]; then
	echo "DEVBOX_JWT_SECRET exists and is non-empty AND DEVBOX_ENV is not production"
	echo "WARNING: The sdk server will be run as root, which is not recommended"
	# start the longrun devbox sdk server service as root.
	export HOME=/root
	export USER=root
	export LOGNAME=root
	exec /usr/sbin/devbox-sdk-server "${sdk_server_args[@]}"
fi

echo "DEVBOX_JWT_SECRET exists and is non-empty AND DEVBOX_ENV is not production"
# start the longrun devbox sdk server service as devbox.
export HOME=/home/devbox
export USER=devbox
export LOGNAME=devbox
exec s6-setuidgid devbox /usr/sbin/devbox-sdk-server "${sdk_server_args[@]}"
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
elif [ "$EXIT_CODE" = "102" ]; then
	echo "Devbox SDK Server is disabled when DEVBOX_ENV=production. Preventing s6 restart."
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

#!/bin/bash
set -euo pipefail

if [ "$(id -u)" -eq 0 ] && [ "${DEVBOX_ENTRYPOINT_AS_DEVBOX:-1}" = "1" ] && id devbox >/dev/null 2>&1; then
    export DEVBOX_ENTRYPOINT_AS_DEVBOX=0
    SCRIPT_PATH=$(readlink -f "$0")
    exec runuser -u devbox -- bash "$SCRIPT_PATH" "$@"
fi

NGINX_BIN=${NGINX_BIN:-/usr/sbin/nginx}
NGINX_CONFIG=${NGINX_CONFIG:-/etc/nginx/nginx.conf}

mkdir -p \
    /tmp/nginx-devbox/client-body \
    /tmp/nginx-devbox/proxy \
    /tmp/nginx-devbox/fastcgi \
    /tmp/nginx-devbox/uwsgi \
    /tmp/nginx-devbox/scgi

# check nginx config
"$NGINX_BIN" -t -c "$NGINX_CONFIG"

# run nginx in foreground
exec "$NGINX_BIN" -c "$NGINX_CONFIG" -g 'daemon off;'

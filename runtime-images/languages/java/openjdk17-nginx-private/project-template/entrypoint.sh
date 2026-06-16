#!/bin/bash
set -euo pipefail

if [ "$(id -u)" -eq 0 ] && [ "${DEVBOX_ENTRYPOINT_AS_DEVBOX:-1}" = "1" ] && id devbox >/dev/null 2>&1; then
    export DEVBOX_ENTRYPOINT_AS_DEVBOX=0
    SCRIPT_PATH=$(readlink -f "$0")
    exec runuser -u devbox -- bash "$SCRIPT_PATH" "$@"
fi

app_env=${1:-development}
build_target=${JAVA_BUILD_TARGET:-HelloWorld}
java_app_port=${JAVA_APP_PORT:-18080}
nginx_bin=${NGINX_BIN:-/usr/sbin/nginx}
nginx_config=${NGINX_CONFIG:-/etc/nginx/nginx.conf}
java_pid=""
nginx_pid=""

mkdir -p \
    /tmp/nginx-devbox/client-body \
    /tmp/nginx-devbox/proxy \
    /tmp/nginx-devbox/fastcgi \
    /tmp/nginx-devbox/uwsgi \
    /tmp/nginx-devbox/scgi

compile_app() {
    javac "${build_target}.java"
}

start_java_app() {
    JAVA_APP_PORT="$java_app_port" java "$build_target" &
    java_pid=$!
}

stop_java_app() {
    if [ -n "${java_pid:-}" ] && kill -0 "$java_pid" >/dev/null 2>&1; then
        kill "$java_pid" >/dev/null 2>&1 || true
        wait "$java_pid" >/dev/null 2>&1 || true
    fi
}

stop_services() {
    trap - EXIT INT TERM
    if [ -n "${nginx_pid:-}" ] && kill -0 "$nginx_pid" >/dev/null 2>&1; then
        kill "$nginx_pid" >/dev/null 2>&1 || true
        wait "$nginx_pid" >/dev/null 2>&1 || true
    fi
    stop_java_app
}

trap stop_services EXIT INT TERM

if [ "$app_env" = "production" ] || [ "$app_env" = "prod" ]; then
    echo "Production environment detected"
else
    echo "Development environment detected"
fi

compile_app
start_java_app

"$nginx_bin" -t -c "$nginx_config"
"$nginx_bin" -c "$nginx_config" -g 'daemon off;' &
nginx_pid=$!

wait -n "$java_pid" "$nginx_pid"

#!/usr/bin/env bash
set -euo pipefail

L10N=${L10N:-en_US}
PYTHON_VERSION=${PYTHON_VERSION:-3.14.0}
DEFAULT_DEVBOX_USER=${DEFAULT_DEVBOX_USER:-devbox}
CODEX_GATEWAY_ROOT=${CODEX_GATEWAY_ROOT:-/opt/codex-gateway}
CODEX_GATEWAY_CODEX_HOME=${CODEX_GATEWAY_CODEX_HOME:-/codex-home}
S6_DIR=/etc/s6-overlay/s6-rc.d
CODEX_GATEWAY_SERVICE_SOURCE_DIR=${CODEX_GATEWAY_SERVICE_SOURCE_DIR:-/tmp/codex-gateway-service}
DEVBOX_HOME="$(getent passwd "$DEFAULT_DEVBOX_USER" | cut -d: -f6 || true)"
if [ -z "$DEVBOX_HOME" ]; then
    DEVBOX_HOME="/home/${DEFAULT_DEVBOX_USER}"
fi
WORKSPACE_DIR=${CODEX_GATEWAY_CWD:-${DEVBOX_HOME}/workspace}
PROJECT_DIR=${PROJECT_DIR:-${DEVBOX_HOME}/project}

apt-get update && \
    apt-get install -y wget build-essential libncursesw5-dev libssl-dev bubblewrap \
        libsqlite3-dev tk-dev libgdbm-dev libc6-dev libbz2-dev libffi-dev zlib1g-dev && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*

wget "https://www.python.org/ftp/python/${PYTHON_VERSION}/Python-${PYTHON_VERSION}.tgz" && \
    tar xzf "Python-${PYTHON_VERSION}.tgz" && \
    cd "Python-${PYTHON_VERSION}" && \
    ./configure --enable-optimizations && \
    make -j "$(nproc)" && \
    make altinstall && \
    cd .. && \
    rm -rf "Python-${PYTHON_VERSION}" "Python-${PYTHON_VERSION}.tgz" && \
    ln -sf /usr/local/bin/python3.14 /usr/bin/python3 && \
    ln -sf /usr/local/bin/python3.14 /usr/bin/python && \
    python3.14 -m ensurepip --upgrade && \
    ln -sf /usr/local/bin/pip3.14 /usr/bin/pip && \
    ln -sf /usr/local/bin/pip3.14 /usr/bin/pip3

npm install -g bun@latest
npm install -g @openai/codex@latest

if [ "$L10N" = "zh_CN" ]; then
    npm config set registry https://registry.npmmirror.com
    pip3.14 config set global.index-url https://mirrors.tuna.tsinghua.edu.cn/pypi/web/simple || true
fi

node --version
bun --version
python3.14 --version

rm -rf "$PROJECT_DIR"

mkdir -p "$WORKSPACE_DIR" "$CODEX_GATEWAY_CODEX_HOME" "$S6_DIR/codex-gateway/dependencies.d"

install -d -m 755 "$CODEX_GATEWAY_ROOT"
printf 'longrun\n' >"$S6_DIR/codex-gateway/type"
install -m 700 \
    "$CODEX_GATEWAY_SERVICE_SOURCE_DIR/run" \
    "$S6_DIR/codex-gateway/run"
install -m 700 \
    "$CODEX_GATEWAY_SERVICE_SOURCE_DIR/finish" \
    "$S6_DIR/codex-gateway/finish"
touch "$S6_DIR/codex-gateway/dependencies.d/startup"
: >"$S6_DIR/user/contents.d/codex-gateway"

chown -R "$DEFAULT_DEVBOX_USER:$DEFAULT_DEVBOX_USER" "$WORKSPACE_DIR" "$CODEX_GATEWAY_CODEX_HOME"

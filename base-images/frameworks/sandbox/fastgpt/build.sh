#!/usr/bin/env bash
set -euo pipefail

L10N=${L10N:-en_US}
PYTHON_VERSION=${PYTHON_VERSION:-3.14.0}
KUBECTL_VERSION=${KUBECTL_VERSION:-v1.33.0}
HELM_VERSION=${HELM_VERSION:-v3.20.2}
DEFAULT_DEVBOX_USER=${DEFAULT_DEVBOX_USER:-devbox}
CODEX_GATEWAY_ROOT=${CODEX_GATEWAY_ROOT:-/opt/codex-gateway}
CODEX_GATEWAY_CODEX_HOME=${CODEX_GATEWAY_CODEX_HOME:-/codex-home}
S6_DIR=/etc/s6-overlay/s6-rc.d
CODEX_GATEWAY_SERVICE_SOURCE_DIR=${CODEX_GATEWAY_SERVICE_SOURCE_DIR:-/tmp/codex-gateway-service}
FASTGPT_IDE_AGENT_SERVICE_SOURCE_DIR=${FASTGPT_IDE_AGENT_SERVICE_SOURCE_DIR:-/tmp/fastgpt-ide-agent}
DEVBOX_HOME="$(getent passwd "$DEFAULT_DEVBOX_USER" | cut -d: -f6 || true)"
if [ -z "$DEVBOX_HOME" ]; then
    DEVBOX_HOME="/home/${DEFAULT_DEVBOX_USER}"
fi
WORKSPACE_DIR=${CODEX_GATEWAY_CWD:-${DEVBOX_HOME}/workspace}
PROJECT_DIR=${PROJECT_DIR:-${DEVBOX_HOME}/project}

ARCH="$(dpkg --print-architecture)"
case "$ARCH" in
    amd64)
        KUBECTL_ARCH=amd64
        ;;
    arm64)
        KUBECTL_ARCH=arm64
        ;;
    *)
        echo "Unsupported architecture for kubectl: $ARCH" >&2
        exit 1
        ;;
esac

apt-get update && \
    apt-get install -y wget build-essential libncursesw5-dev libssl-dev bubblewrap \
        ripgrep \
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
apt-get clean && \
    rm -rf /var/lib/apt/lists/*

wget -O /usr/local/bin/kubectl \
    "https://dl.k8s.io/release/${KUBECTL_VERSION}/bin/linux/${KUBECTL_ARCH}/kubectl" && \
    chmod 0755 /usr/local/bin/kubectl

wget -O "/tmp/helm-${HELM_VERSION}-linux-${KUBECTL_ARCH}.tar.gz" \
    "https://get.helm.sh/helm-${HELM_VERSION}-linux-${KUBECTL_ARCH}.tar.gz" && \
    tar -C /tmp -xzf "/tmp/helm-${HELM_VERSION}-linux-${KUBECTL_ARCH}.tar.gz" && \
    install -m 0755 "/tmp/linux-${KUBECTL_ARCH}/helm" /usr/local/bin/helm && \
    rm -rf "/tmp/helm-${HELM_VERSION}-linux-${KUBECTL_ARCH}.tar.gz" "/tmp/linux-${KUBECTL_ARCH}"

if [ "$L10N" = "zh_CN" ]; then
    npm config set registry https://registry.npmmirror.com
    HOME=/root pip3.14 config set global.index-url https://mirrors.tuna.tsinghua.edu.cn/pypi/web/simple
    HOME="$DEVBOX_HOME" pip3.14 config set global.index-url https://mirrors.tuna.tsinghua.edu.cn/pypi/web/simple
    chown -R "$DEFAULT_DEVBOX_USER:$DEFAULT_DEVBOX_USER" "$DEVBOX_HOME/.config" 2>/dev/null || true
fi

node --version
bun --version
kubectl version --client
helm version --short
python3.14 --version
rg --version

rm -rf "$PROJECT_DIR"

mkdir -p \
    "$WORKSPACE_DIR" \
    "$CODEX_GATEWAY_CODEX_HOME" \
    "$S6_DIR/codex-gateway/dependencies.d" \
    "$S6_DIR/fastgpt-ide-agent/dependencies.d"

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

printf 'longrun\n' >"$S6_DIR/fastgpt-ide-agent/type"
install -m 700 \
    "$FASTGPT_IDE_AGENT_SERVICE_SOURCE_DIR/run" \
    "$S6_DIR/fastgpt-ide-agent/run"
install -m 700 \
    "$FASTGPT_IDE_AGENT_SERVICE_SOURCE_DIR/finish" \
    "$S6_DIR/fastgpt-ide-agent/finish"
touch "$S6_DIR/fastgpt-ide-agent/dependencies.d/startup"
: >"$S6_DIR/user/contents.d/fastgpt-ide-agent"

chown -R "$DEFAULT_DEVBOX_USER:$DEFAULT_DEVBOX_USER" "$WORKSPACE_DIR" "$CODEX_GATEWAY_CODEX_HOME"

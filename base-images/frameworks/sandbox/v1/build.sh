#!/usr/bin/env bash
set -euo pipefail

L10N=${L10N:-en_US}
PYTHON_VERSION=${PYTHON_VERSION:-3.14.0}
KUBECTL_VERSION=${KUBECTL_VERSION:-v1.33.0}
HELM_VERSION=${HELM_VERSION:-v3.20.2}
BUILDKIT_VERSION=${BUILDKIT_VERSION:-v0.30.0}
RAILPACK_VERSION=${RAILPACK_VERSION:-0.27.0}
VERSITYGW_VERSION=${VERSITYGW_VERSION:-1.5.0}
DEFAULT_DEVBOX_USER=${DEFAULT_DEVBOX_USER:-devbox}
CODEX_GATEWAY_ROOT=${CODEX_GATEWAY_ROOT:-/opt/codex-gateway}
CODEX_GATEWAY_CODEX_HOME=${CODEX_GATEWAY_CODEX_HOME:-/codex-home}
S6_DIR=/etc/s6-overlay/s6-rc.d
CODEX_GATEWAY_SERVICE_SOURCE_DIR=${CODEX_GATEWAY_SERVICE_SOURCE_DIR:-/tmp/codex-gateway-service}
VERSITYGW_SERVICE_SOURCE_DIR=${VERSITYGW_SERVICE_SOURCE_DIR:-/tmp/versitygw-service}
DEVBOX_HOME="$(getent passwd "$DEFAULT_DEVBOX_USER" | cut -d: -f6 || true)"
if [ -z "$DEVBOX_HOME" ]; then
    DEVBOX_HOME="/home/${DEFAULT_DEVBOX_USER}"
fi
WORKSPACE_DIR=${CODEX_GATEWAY_CWD:-${DEVBOX_HOME}/workspace}
PROJECT_DIR=${PROJECT_DIR:-${DEVBOX_HOME}/project}
VERSITYGW_ROOT=${VERSITYGW_ROOT:-${WORKSPACE_DIR}/.versitygw-s3}
VERSITYGW_IAM_DIR=${VERSITYGW_IAM_DIR:-${WORKSPACE_DIR}/.versitygw-iam}
VERSITYGW_VERSIONING_DIR=${VERSITYGW_VERSIONING_DIR:-${WORKSPACE_DIR}/.versitygw-versioning}
KANIKO_CONTEXT_S3_BUCKET=${KANIKO_CONTEXT_S3_BUCKET:-kaniko-contexts}
KANIKO_CONTEXT_S3_PREFIX=${KANIKO_CONTEXT_S3_PREFIX:-contexts}

ARCH="$(dpkg --print-architecture)"
case "$ARCH" in
    amd64)
        KUBECTL_ARCH=amd64
        BUILDKIT_ARCH=amd64
        RAILPACK_ARCH=x86_64
        VERSITYGW_ARCH=amd64
        ;;
    arm64)
        KUBECTL_ARCH=arm64
        BUILDKIT_ARCH=arm64
        RAILPACK_ARCH=arm64
        VERSITYGW_ARCH=arm64
        ;;
    *)
        echo "Unsupported architecture for kubectl/buildkit/versitygw: $ARCH" >&2
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

wget -O /usr/local/bin/kubectl \
    "https://dl.k8s.io/release/${KUBECTL_VERSION}/bin/linux/${KUBECTL_ARCH}/kubectl" && \
    chmod 0755 /usr/local/bin/kubectl

wget -O "/tmp/helm-${HELM_VERSION}-linux-${KUBECTL_ARCH}.tar.gz" \
    "https://get.helm.sh/helm-${HELM_VERSION}-linux-${KUBECTL_ARCH}.tar.gz" && \
    tar -C /tmp -xzf "/tmp/helm-${HELM_VERSION}-linux-${KUBECTL_ARCH}.tar.gz" && \
    install -m 0755 "/tmp/linux-${KUBECTL_ARCH}/helm" /usr/local/bin/helm && \
    rm -rf "/tmp/helm-${HELM_VERSION}-linux-${KUBECTL_ARCH}.tar.gz" "/tmp/linux-${KUBECTL_ARCH}"

wget -O "/tmp/buildkit-${BUILDKIT_VERSION}.linux-${BUILDKIT_ARCH}.tar.gz" \
    "https://github.com/moby/buildkit/releases/download/${BUILDKIT_VERSION}/buildkit-${BUILDKIT_VERSION}.linux-${BUILDKIT_ARCH}.tar.gz" && \
    tar -C /tmp -xzf "/tmp/buildkit-${BUILDKIT_VERSION}.linux-${BUILDKIT_ARCH}.tar.gz" && \
    install -m 0755 /tmp/bin/buildctl /usr/local/bin/buildctl && \
    rm -rf "/tmp/buildkit-${BUILDKIT_VERSION}.linux-${BUILDKIT_ARCH}.tar.gz" /tmp/bin

wget -O "/tmp/railpack-v${RAILPACK_VERSION}-${RAILPACK_ARCH}-unknown-linux-musl.tar.gz" \
    "https://github.com/railwayapp/railpack/releases/download/v${RAILPACK_VERSION}/railpack-v${RAILPACK_VERSION}-${RAILPACK_ARCH}-unknown-linux-musl.tar.gz" && \
    tar -C /usr/local/bin -xzf "/tmp/railpack-v${RAILPACK_VERSION}-${RAILPACK_ARCH}-unknown-linux-musl.tar.gz" && \
    chmod 0755 /usr/local/bin/railpack && \
    rm -f "/tmp/railpack-v${RAILPACK_VERSION}-${RAILPACK_ARCH}-unknown-linux-musl.tar.gz"

wget -O "/tmp/versitygw_${VERSITYGW_VERSION}_linux_${VERSITYGW_ARCH}.deb" \
    "https://github.com/versity/versitygw/releases/download/v${VERSITYGW_VERSION}/versitygw_${VERSITYGW_VERSION}_linux_${VERSITYGW_ARCH}.deb" && \
    dpkg -i "/tmp/versitygw_${VERSITYGW_VERSION}_linux_${VERSITYGW_ARCH}.deb" && \
    rm -f "/tmp/versitygw_${VERSITYGW_VERSION}_linux_${VERSITYGW_ARCH}.deb"

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
buildctl --version
railpack --version
versitygw --version
python3.14 --version
rg --version

rm -rf "$PROJECT_DIR"

mkdir -p \
    "$WORKSPACE_DIR" \
    "$CODEX_GATEWAY_CODEX_HOME" \
    "$VERSITYGW_ROOT/$KANIKO_CONTEXT_S3_BUCKET/$KANIKO_CONTEXT_S3_PREFIX" \
    "$VERSITYGW_IAM_DIR" \
    "$VERSITYGW_VERSIONING_DIR" \
    "$S6_DIR/codex-gateway/dependencies.d" \
    "$S6_DIR/versitygw/dependencies.d"

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

printf 'longrun\n' >"$S6_DIR/versitygw/type"
install -m 700 \
    "$VERSITYGW_SERVICE_SOURCE_DIR/run" \
    "$S6_DIR/versitygw/run"
install -m 700 \
    "$VERSITYGW_SERVICE_SOURCE_DIR/finish" \
    "$S6_DIR/versitygw/finish"
touch "$S6_DIR/versitygw/dependencies.d/startup"
: >"$S6_DIR/user/contents.d/versitygw"

cat >/etc/profile.d/versitygw-kaniko-context.sh <<'PROFILE'
# Runtime S3 endpoint backed by versitygw POSIX storage for kaniko contexts.
export AWS_ACCESS_KEY_ID="${AWS_ACCESS_KEY_ID:-admin}"
export AWS_REGION="${AWS_REGION:-sealos-internal}"
export AWS_DEFAULT_REGION="${AWS_DEFAULT_REGION:-${AWS_REGION}}"
export AWS_ENDPOINT_URL="${AWS_ENDPOINT_URL:-http://127.0.0.1:1319}"
export AWS_ENDPOINT_URL_S3="${AWS_ENDPOINT_URL_S3:-${AWS_ENDPOINT_URL}}"
export AWS_S3_FORCE_PATH_STYLE="${AWS_S3_FORCE_PATH_STYLE:-true}"
export S3_ENDPOINT="${S3_ENDPOINT:-${AWS_ENDPOINT_URL_S3}}"
export S3_FORCE_PATH_STYLE="${S3_FORCE_PATH_STYLE:-true}"
if [ -z "${AWS_SECRET_ACCESS_KEY:-}" ]; then
    export AWS_SECRET_ACCESS_KEY="${SEALOS_DEVBOX_JWT_SECRET:-${DEVBOX_JWT_SECRET:-}}"
fi
export KANIKO_CONTEXT_S3_BUCKET="${KANIKO_CONTEXT_S3_BUCKET:-kaniko-contexts}"
export KANIKO_CONTEXT_S3_PREFIX="${KANIKO_CONTEXT_S3_PREFIX:-contexts}"
export KANIKO_CONTEXT_S3_BASE="${KANIKO_CONTEXT_S3_BASE:-s3://${KANIKO_CONTEXT_S3_BUCKET}/${KANIKO_CONTEXT_S3_PREFIX}}"
export KANIKO_CONTEXT_POSIX_DIR="${KANIKO_CONTEXT_POSIX_DIR:-${VERSITYGW_ROOT:-/home/devbox/workspace/.versitygw-s3}/${KANIKO_CONTEXT_S3_BUCKET}/${KANIKO_CONTEXT_S3_PREFIX}}"
PROFILE
chmod 0644 /etc/profile.d/versitygw-kaniko-context.sh

chown -R \
    "$DEFAULT_DEVBOX_USER:$DEFAULT_DEVBOX_USER" \
    "$WORKSPACE_DIR" \
    "$CODEX_GATEWAY_CODEX_HOME"

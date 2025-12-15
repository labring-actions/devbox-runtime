#!/usr/bin/env bash
set -euo pipefail

L10N=${L10N:-en_US}
DEFAULT_DEVBOX_USER=${DEFAULT_DEVBOX_USER:-devbox}

# Install Go 1.22.5
curl -O https://dl.google.com/go/go1.22.5.linux-amd64.tar.gz && \
rm -rf /usr/local/go && tar -C /usr/local -xzf go1.22.5.linux-amd64.tar.gz


# Set up Go for root
ROOT_HOME="${HOME:-/root}"
if [ "$L10N" = "zh_CN" ]; then
    grep -qxF 'export GOPROXY=https://goproxy.cn,direct' "$ROOT_HOME/.bashrc" || \
        echo 'export GOPROXY=https://goproxy.cn,direct' >> "$ROOT_HOME/.bashrc"
fi
mkdir -p "$ROOT_HOME/go/bin"
grep -qxF 'export GOPATH=$HOME/go' "$ROOT_HOME/.bashrc" || \
    echo 'export GOPATH=$HOME/go' >> "$ROOT_HOME/.bashrc"
grep -qxF 'export PATH=$PATH:/usr/local/go/bin:$HOME/go/bin' "$ROOT_HOME/.bashrc" || \
    echo 'export PATH=$PATH:/usr/local/go/bin:$HOME/go/bin' >> "$ROOT_HOME/.bashrc"

# Set up Go for devbox user
DEVBOX_USER="${DEFAULT_DEVBOX_USER}"
DEVBOX_HOME="$(getent passwd "$DEVBOX_USER" | cut -d: -f6 || true)"
if [ -z "$DEVBOX_HOME" ]; then
    DEVBOX_HOME="/home/${DEVBOX_USER}"
fi

if [ "$L10N" = "zh_CN" ]; then
    grep -qxF 'export GOPROXY=https://goproxy.cn,direct' "$DEVBOX_HOME/.bashrc" 2>/dev/null || \
        echo 'export GOPROXY=https://goproxy.cn,direct' >> "$DEVBOX_HOME/.bashrc"
fi
mkdir -p "$DEVBOX_HOME/go/bin"
chown -R "${DEVBOX_USER}:${DEVBOX_USER}" "$DEVBOX_HOME/go" || true

grep -qxF 'export GOPATH=$HOME/go' "$DEVBOX_HOME/.bashrc" 2>/dev/null || \
    echo 'export GOPATH=$HOME/go' >> "$DEVBOX_HOME/.bashrc"
grep -qxF 'export PATH=$PATH:/usr/local/go/bin:$HOME/go/bin' "$DEVBOX_HOME/.bashrc" 2>/dev/null || \
    echo 'export PATH=$PATH:/usr/local/go/bin:$HOME/go/bin' >> "$DEVBOX_HOME/.bashrc"


#!/usr/bin/env bash
set -euo pipefail

L10N=${L10N:-en_US}
DEFAULT_DEVBOX_USER=${DEFAULT_DEVBOX_USER:-devbox}

configure_pip_mirror() {
    local pip_cmd="$1"
    local user_home="$2"
    local owner="${3:-}"

    mkdir -p "$user_home"
    HOME="$user_home" "$pip_cmd" config set global.index-url https://mirrors.tuna.tsinghua.edu.cn/pypi/web/simple

    if [ -n "$owner" ]; then
        chown -R "$owner:$owner" "$user_home/.config" 2>/dev/null || true
    fi
}

# Install build dependencies
# Note: wget and make are already installed in the Debian base image layer via install-base-pkg-deb.sh
apt-get update && \
    apt-get install -y build-essential libncursesw5-dev libssl-dev \
        libsqlite3-dev tk-dev libgdbm-dev libc6-dev libbz2-dev libffi-dev zlib1g-dev && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*

# Download and compile Python 3.11
wget https://www.python.org/ftp/python/3.11.11/Python-3.11.11.tgz && \
    tar xzf Python-3.11.11.tgz && \
    cd Python-3.11.11 && \
    ./configure --enable-optimizations && \
    make -j "$(nproc)" && \
    make altinstall && \
    cd .. && \
    rm -rf Python-3.11.11 Python-3.11.11.tgz && \
    ln -s /usr/local/bin/python3.11 /usr/bin/python3 && \
    ln -s /usr/local/bin/python3.11 /usr/bin/python && \
    python3.11 -m ensurepip --upgrade && \
    ln -s /usr/local/bin/pip3.11 /usr/bin/pip && \
    ln -s /usr/local/bin/pip3.11 /usr/bin/pip3

if [ "$L10N" = "zh_CN" ]; then
    configure_pip_mirror pip3.11 /root

    DEVBOX_HOME="$(getent passwd "$DEFAULT_DEVBOX_USER" | cut -d: -f6 || true)"
    if [ -z "$DEVBOX_HOME" ]; then
        DEVBOX_HOME="/home/${DEFAULT_DEVBOX_USER}"
    fi
    configure_pip_mirror pip3.11 "$DEVBOX_HOME" "$DEFAULT_DEVBOX_USER"
fi

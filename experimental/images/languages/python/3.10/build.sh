#!/usr/bin/env bash
set -euo pipefail

L10N=${L10N:-en_US}
DEFAULT_DEVBOX_USER=${DEFAULT_DEVBOX_USER:-devbox}

# Install build dependencies
# Note: wget and make are already installed in images/debian-12.6 via install-base-pkg-deb.sh
apt-get update && \
    apt-get install -y build-essential libncursesw5-dev libssl-dev \
        libsqlite3-dev tk-dev libgdbm-dev libc6-dev libbz2-dev libffi-dev zlib1g-dev && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*

# Download and compile Python 3.10
wget https://www.python.org/ftp/python/3.10.16/Python-3.10.16.tgz && \
    tar xzf Python-3.10.16.tgz && \
    cd Python-3.10.16 && \
    ./configure --enable-optimizations && \
    make -j $(nproc) && \
    make altinstall && \
    cd .. && \
    rm -rf Python-3.10.16 Python-3.10.16.tgz && \
    ln -s /usr/local/bin/python3.10 /usr/bin/python3 && \
    ln -s /usr/local/bin/python3.10 /usr/bin/python && \
    python3.10 -m ensurepip --upgrade && \
    ln -s /usr/local/bin/pip3.10 /usr/bin/pip && \
    ln -s /usr/local/bin/pip3.10 /usr/bin/pip3

# Configure pip for Chinese users (if L10N is zh_CN)
if [ "$L10N" = "zh_CN" ]; then
    pip3.10 config set global.index-url https://mirrors.tuna.tsinghua.edu.cn/pypi/web/simple || true
fi

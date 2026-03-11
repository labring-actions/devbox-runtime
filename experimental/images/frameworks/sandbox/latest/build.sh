#!/usr/bin/env bash
set -euo pipefail

L10N=${L10N:-en_US}
PYTHON_VERSION=${PYTHON_VERSION:-3.14.0}

apt-get update && \
    apt-get install -y wget build-essential libncursesw5-dev libssl-dev \
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

if [ "$L10N" = "zh_CN" ]; then
    npm config set registry https://registry.npmmirror.com
    pip3.14 config set global.index-url https://mirrors.tuna.tsinghua.edu.cn/pypi/web/simple || true
fi

node --version
bun --version
python3.14 --version

rm -rf /home/devbox/project

mkdir -p /home/devbox/workspace
chown -R devbox:devbox /home/devbox/workspace

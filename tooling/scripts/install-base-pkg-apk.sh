#!/usr/bin/env bash
set -euo pipefail

if ! command -v apk >/dev/null 2>&1; then
    echo "apk is not available" >&2
    exit 1
fi

apk add --no-cache \
    bash \
    binutils \
    busybox \
    ca-certificates \
    coreutils \
    cpio \
    curl \
    diffutils \
    findutils \
    gawk \
    gcompat \
    git \
    grep \
    gzip \
    iproute2 \
    libgcc \
    libstdc++ \
    logrotate \
    openssh \
    openssh-client \
    openssh-server \
    openssl \
    procps \
    python3 \
    sed \
    shadow \
    sudo \
    tar \
    tzdata \
    unzip \
    util-linux \
    vim \
    wget \
    which \
    xz \
    zip

update-ca-certificates

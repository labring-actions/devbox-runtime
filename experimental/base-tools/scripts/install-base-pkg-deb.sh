#!/usr/bin/env bash
set -euo pipefail

apt-get update && \
    apt-get install -y \
    wget \
    curl \
    sudo \
    vim \
    openssl \
    git \
    xz-utils \
    openssh-client \
    anacron \
    logrotate \
    openssh-server \
    locales \
    ca-certificates \
    busybox \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*

DEBIAN_FRONTEND=noninteractive apt-get install -y tzdata

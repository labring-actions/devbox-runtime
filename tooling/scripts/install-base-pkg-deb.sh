#!/usr/bin/env bash
set -euo pipefail

apt-get update && \
    apt-get install -y \
    wget \
    curl \
    sudo \
    vim \
    less \
    file \
    jq \
    openssl \
    git \
    xz-utils \
    zip \
    unzip \
    openssh-client \
    anacron \
    logrotate \
    openssh-server \
    locales \
    ca-certificates \
    busybox \
    procps \
    iproute2 \
    iputils-ping \
    lsof \
    rsync

DEBIAN_FRONTEND=noninteractive apt-get install -y tzdata

apt-get clean && \
rm -rf /var/lib/apt/lists/*

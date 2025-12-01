#!/usr/bin/env bash
set -euo pipefail

export DEBIAN_FRONTEND=noninteractive
apt-get update && \
    apt-get install -y \
    wget \
    sudo \
    vim \
    openssl \
    make \
    git \
    xz-utils \
    openssh-client \
    anacron \
    logrotate \
    openssh-server \
    locales


# Install base-tools
# Determine architecture and set ARCH environment variable which is used by the install scripts
export ARCH="$(dpkg --print-architecture)"
export BASE_TOOLS_DIR=${BASE_TOOLS_DIR:-/opt/base-tools}
$BASE_TOOLS_DIR/scripts/install-crond.sh
$BASE_TOOLS_DIR/scripts/install-s6.sh

# Configure svc
# Important: s6 must be configured before other services that depend on it
$BASE_TOOLS_DIR/scripts/svc/configure-s6.sh

# Configure pre-rc-init hook FIRST
# This hook runs BEFORE s6-rc compilation, allowing us to disable services
# based on DEVBOX_ENV environment variable
$BASE_TOOLS_DIR/scripts/svc/configure-pre-rc-init.sh

# Configure individual services
$BASE_TOOLS_DIR/scripts/svc/configure-startup.sh
$BASE_TOOLS_DIR/scripts/svc/configure-sshd.sh
$BASE_TOOLS_DIR/scripts/svc/configure-crond.sh


# Configure other utilities
$BASE_TOOLS_DIR/scripts/configure-logrotate.sh
$BASE_TOOLS_DIR/scripts/configure-login.sh


# Cleanup apt cache
$BASE_TOOLS_DIR/scripts/deb-cleanup.sh
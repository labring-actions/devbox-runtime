#!/usr/bin/env bash
set -euo pipefail

L10N=${L10N:-en_US}
DEFAULT_DEVBOX_USER=${DEFAULT_DEVBOX_USER:-devbox}

# Install Node.js 20 from NodeSource
# Note: curl is already installed in images/debian-12.6 via install-base-pkg-deb.sh
curl -sL https://deb.nodesource.com/setup_20.x | bash - && \
    apt-get install -y nodejs && \
    npm install -y -g typescript yarn pnpm && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*

# Configure npm registry for Chinese users (if L10N is zh_CN)
if [ "$L10N" = "zh_CN" ]; then
    npm config set registry https://registry.npmmirror.com
fi

# Set up NVM for devbox user (optional, for version management)
DEVBOX_USER="${DEFAULT_DEVBOX_USER}"
DEVBOX_HOME="$(getent passwd "$DEVBOX_USER" | cut -d: -f6 || true)"
if [ -z "$DEVBOX_HOME" ]; then
    DEVBOX_HOME="/home/${DEVBOX_USER}"
fi

# Install NVM for devbox user
export NVM_DIR="$DEVBOX_HOME/.nvm"
mkdir -p "$NVM_DIR"
curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.40.0/install.sh | bash || true
chown -R "${DEVBOX_USER}:${DEVBOX_USER}" "$NVM_DIR" || true


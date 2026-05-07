#!/usr/bin/env bash
set -euo pipefail

L10N=${L10N:-en_US}
DEFAULT_DEVBOX_USER=${DEFAULT_DEVBOX_USER:-devbox}

# Install Node.js 18 from NodeSource
# Note: curl is already installed in the Debian base image layer via install-base-pkg-deb.sh
curl -sL https://deb.nodesource.com/setup_18.x | bash - && \
    apt-get install -y nodejs && \
    npm install -y -g typescript yarn pnpm && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*

# Set up NVM for devbox user (optional, for version management)
DEVBOX_USER="${DEFAULT_DEVBOX_USER}"
DEVBOX_HOME="$(getent passwd "$DEVBOX_USER" | cut -d: -f6 || true)"
if [ -z "$DEVBOX_HOME" ]; then
    DEVBOX_HOME="/home/${DEVBOX_USER}"
fi

# Configure npm registry for Chinese users (if L10N is zh_CN). Write both
# global and user config so non-login root/devbox checks see the same source.
if [ "$L10N" = "zh_CN" ]; then
    npm config set --global registry https://registry.npmmirror.com/
    printf '%s\n' 'registry=https://registry.npmmirror.com/' >/etc/npmrc
    printf '%s\n' 'registry=https://registry.npmmirror.com/' >/root/.npmrc
    install -d -m 0755 -o "$DEVBOX_USER" -g "$DEVBOX_USER" "$DEVBOX_HOME"
    printf '%s\n' 'registry=https://registry.npmmirror.com/' >"$DEVBOX_HOME/.npmrc"
    chown "$DEVBOX_USER:$DEVBOX_USER" "$DEVBOX_HOME/.npmrc"
fi

# Install NVM for devbox user
export NVM_DIR="$DEVBOX_HOME/.nvm"
mkdir -p "$NVM_DIR"
curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.40.0/install.sh | bash || true
chown -R "${DEVBOX_USER}:${DEVBOX_USER}" "$NVM_DIR" || true

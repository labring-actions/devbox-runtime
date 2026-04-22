#!/usr/bin/env bash
set -euo pipefail

L10N=${L10N:-en_US}
DEFAULT_DEVBOX_USER=${DEFAULT_DEVBOX_USER:-devbox}

# Install build dependencies
# Note: curl and make are already installed in images/debian-12.6 via install-base-pkg-deb.sh
apt-get update && \
    apt-get install -y build-essential libudev-dev pkg-config && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*

# Set up Rust for root
ROOT_HOME="${HOME:-/root}"
grep -qxF 'export PATH=/home/devbox/.cargo/bin:$PATH' "$ROOT_HOME/.bashrc" || \
    echo 'export PATH=/home/devbox/.cargo/bin:$PATH' >> "$ROOT_HOME/.bashrc"
grep -qxF '. /home/devbox/.cargo/env' "$ROOT_HOME/.bashrc" || \
    echo '. /home/devbox/.cargo/env' >> "$ROOT_HOME/.bashrc"

# Set up Rust for devbox user
DEVBOX_USER="${DEFAULT_DEVBOX_USER}"
DEVBOX_HOME="$(getent passwd "$DEVBOX_USER" | cut -d: -f6 || true)"
if [ -z "$DEVBOX_HOME" ]; then
    DEVBOX_HOME="/home/${DEVBOX_USER}"
fi

# Install Rust for devbox user
# Note: Rust installation needs to be done as the devbox user, but we're running as root
# So we'll create the directory and install Rust, then fix permissions
mkdir -p "$DEVBOX_HOME/.cargo"
chown -R "${DEVBOX_USER}:${DEVBOX_USER}" "$DEVBOX_HOME/.cargo" || true

# Install Rust using rustup
# We need to run this as the devbox user, but since we're in build.sh (root context),
# we'll use su to switch user
su - "$DEVBOX_USER" -c "curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh -s -- -y" || true

# Set up environment variables for devbox user
grep -qxF 'export PATH=/home/devbox/.cargo/bin:$PATH' "$DEVBOX_HOME/.bashrc" 2>/dev/null || \
    echo 'export PATH=/home/devbox/.cargo/bin:$PATH' >> "$DEVBOX_HOME/.bashrc" 2>/dev/null || true
grep -qxF '. /home/devbox/.cargo/env' "$DEVBOX_HOME/.bashrc" 2>/dev/null || \
    echo '. /home/devbox/.cargo/env' >> "$DEVBOX_HOME/.bashrc" 2>/dev/null || true

# Ensure cargo is in PATH for root as well
export PATH="/home/devbox/.cargo/bin:${PATH}"


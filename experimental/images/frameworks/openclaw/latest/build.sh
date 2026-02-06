#!/usr/bin/env bash
set -euo pipefail

OPENCLAW_VERSION=${OPENCLAW_VERSION:-latest}
DEFAULT_DEVBOX_USER=${DEFAULT_DEVBOX_USER:-devbox}

DEVBOX_HOME="$(getent passwd "$DEFAULT_DEVBOX_USER" | cut -d: -f6 || true)"
if [ -z "$DEVBOX_HOME" ]; then
  DEVBOX_HOME="/home/${DEFAULT_DEVBOX_USER}"
fi

npm install -g "openclaw@${OPENCLAW_VERSION}"
npm install -g bun
npm install -g clawhub

# Install clawhub packages as the devbox user.
if command -v clawhub >/dev/null 2>&1; then
  su - "$DEFAULT_DEVBOX_USER" -c "\
    clawhub install openai-whisper && \
    clawhub install auto-updater && \
    clawhub install marketing-skills && \
    clawhub install kubectl && \
    clawhub install ralph-loops"
else
  echo "clawhub not found; skipping clawhub installs."
fi

ARCH="$(dpkg --print-architecture 2>/dev/null || uname -m)"
case "$ARCH" in
  amd64)
    apt-get update
    apt-get install -y wget
    wget https://dl.google.com/linux/direct/google-chrome-stable_current_amd64.deb
    dpkg -i google-chrome-stable_current_amd64.deb || true
    apt --fix-broken install -y
    dpkg -i google-chrome-stable_current_amd64.deb
    rm -f google-chrome-stable_current_amd64.deb
    ;;
  # TODO: add Chrome install for arm64|aarch64
  # arm64|aarch64)
  #   apt-get update
  #   apt-get install -y chromium
  #   ;;
  *)
    echo "Skipping Chrome install for arch: $ARCH"
    ;;
esac
apt-get clean
rm -rf /var/lib/apt/lists/*

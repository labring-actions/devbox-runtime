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

install_clawhub_skill() {
  local skill="$1"
  local output=""

  if output=$(su - "$DEFAULT_DEVBOX_USER" -c "clawhub install \"$skill\"" 2>&1); then
    printf '%s\n' "$output"
    return 0
  fi

  printf '%s\n' "$output" >&2

  if printf '%s\n' "$output" | grep -q "Use --force to install suspicious skills in non-interactive mode"; then
    if [ "${CLAWHUB_ALLOW_SUSPICIOUS_SKILLS:-false}" = "true" ]; then
      echo "Retrying suspicious skill '$skill' with --force (CLAWHUB_ALLOW_SUSPICIOUS_SKILLS=true)."
      su - "$DEFAULT_DEVBOX_USER" -c "clawhub install --force \"$skill\""
    else
      echo "Skipping suspicious skill '$skill'. Set CLAWHUB_ALLOW_SUSPICIOUS_SKILLS=true to force install."
    fi
    return 0
  fi

  echo "Failed to install clawhub skill '$skill' for a reason unrelated to suspicious-skill policy." >&2
  return 1
}

# Install clawhub packages as the devbox user.
if command -v clawhub >/dev/null 2>&1; then
  install_clawhub_skill openai-whisper
  install_clawhub_skill auto-updater
  install_clawhub_skill marketing-skills
  install_clawhub_skill kubectl
  install_clawhub_skill ralph-loops
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

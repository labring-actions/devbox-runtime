#!/usr/bin/env bash
set -euo pipefail

L10N=${L10N:-en_US}
DEFAULT_DEVBOX_USER=${DEFAULT_DEVBOX_USER:-devbox}
PROJECT_TEMPLATE_DIR=${PROJECT_TEMPLATE_DIR:-/project-template}

if ! id -u "$DEFAULT_DEVBOX_USER" &>/dev/null; then
  echo "User $DEFAULT_DEVBOX_USER does not exist"
  exit 1
fi

TARGET_DIR="/home/$DEFAULT_DEVBOX_USER/project"
mkdir -p "$TARGET_DIR"

if [ -f "$PROJECT_TEMPLATE_DIR/README.$L10N.md" ]; then
  echo "README $PROJECT_TEMPLATE_DIR/README.$L10N.md exists. Copying to $TARGET_DIR/README.md"
  cp "$PROJECT_TEMPLATE_DIR/README.$L10N.md" "$TARGET_DIR/README.md"
else
  echo "README $PROJECT_TEMPLATE_DIR/README.$L10N.md does not exist. Skipping copy."
fi

# Copy project template contents (except localized readmes handled above).
# Using `/.` keeps hidden files/dirs if present.
cp -R "${PROJECT_TEMPLATE_DIR}/." "$TARGET_DIR/"

# Seed runtime config and workspace for the devbox user.
DEVBOX_HOME="$(getent passwd "$DEFAULT_DEVBOX_USER" | cut -d: -f6 || true)"
if [ -z "$DEVBOX_HOME" ]; then
  DEVBOX_HOME="/home/${DEFAULT_DEVBOX_USER}"
fi
mkdir -p "$DEVBOX_HOME/.clawdbot" -p "$TARGET_DIR/workspace"
if [ -f "$PROJECT_TEMPLATE_DIR/clawdbot.json" ]; then
  cp "$PROJECT_TEMPLATE_DIR/clawdbot.json" "$DEVBOX_HOME/.clawdbot/clawdbot.json"
fi

# Seed .env from example if present.
if [ -f "$TARGET_DIR/.env.example" ]; then
  cp "$TARGET_DIR/.env.example" "$TARGET_DIR/.env"
fi

# If we wrote a localized README.md, remove the localized variants to keep the
# project dir clean (optional; safe if they don't exist).
rm -f "$TARGET_DIR/README.en_US.md" "$TARGET_DIR/README.zh_CN.md" || true
rm -r "$TARGET_DIR/clawdbot.json" || true

# Ensure entrypoint is executable if present.
if [ -f "$TARGET_DIR/entrypoint.sh" ]; then
  chmod +x "$TARGET_DIR/entrypoint.sh"
fi

# Set ownership to default devbox user
chown -R "$DEFAULT_DEVBOX_USER:$DEFAULT_DEVBOX_USER" "$TARGET_DIR" "$DEVBOX_HOME/.clawdbot" "$DEVBOX_HOME/workspace"

#!/usr/bin/env bash
set -euo pipefail

L10N=${L10N:-en_US}
DEFAULT_DEVBOX_USER=${DEFAULT_DEVBOX_USER:-devbox}
PROJECT_TEMPLATE_DIR=${PROJECT_TEMPLATE_DIR:-/project-templates}

if ! id -u "$DEFAULT_DEVBOX_USER" &>/dev/null; then
  echo "User $DEFAULT_DEVBOX_USER does not exist"
  exit 1
fi

mkdir -p "/home/$DEFAULT_DEVBOX_USER/project"

if [ -f "$PROJECT_TEMPLATE_DIR/README.$L10N.md" ]; then
  echo "README $PROJECT_TEMPLATE_DIR/README.$L10N.md exists. Copying to /home/$DEFAULT_DEVBOX_USER/project/README.md"
  cp "$PROJECT_TEMPLATE_DIR/README.$L10N.md" "/home/$DEFAULT_DEVBOX_USER/project/README.md"
else 
  echo "README $PROJECT_TEMPLATE_DIR/README.$L10N.md does not exist. Skipping copy."
fi

cp "$PROJECT_TEMPLATE_DIR/"*.sh "/home/$DEFAULT_DEVBOX_USER/project/"

# Set ownership to default devbox user
chown -R "$DEFAULT_DEVBOX_USER:$DEFAULT_DEVBOX_USER" "/home/$DEFAULT_DEVBOX_USER/project"


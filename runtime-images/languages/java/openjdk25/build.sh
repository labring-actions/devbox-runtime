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

DOCS_DIR=${DOCS_DIR:-/usr/share/devbox/docs}
if [ -f "$DOCS_DIR/README.s6-user-guide.$L10N.md" ]; then
  cp "$DOCS_DIR/README.s6-user-guide.$L10N.md" "$TARGET_DIR/README.s6-user-guide.md"
elif [ -f "$DOCS_DIR/README.s6-user-guide.en_US.md" ]; then
  cp "$DOCS_DIR/README.s6-user-guide.en_US.md" "$TARGET_DIR/README.s6-user-guide.md"
fi

cp -R "${PROJECT_TEMPLATE_DIR}/." "$TARGET_DIR/"
rm -f "$TARGET_DIR/README.en_US.md" "$TARGET_DIR/README.zh_CN.md" || true

if [ -f "$TARGET_DIR/entrypoint.sh" ]; then
  chmod +x "$TARGET_DIR/entrypoint.sh"
fi

chown -R "$DEFAULT_DEVBOX_USER:$DEFAULT_DEVBOX_USER" "$TARGET_DIR"

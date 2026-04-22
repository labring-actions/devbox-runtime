#!/usr/bin/env bash
set -euo pipefail

echo "Current BASE_TOOLS_DIR: $BASE_TOOLS_DIR"
echo "Current L10N: $L10N"
echo "Current ARCH: $ARCH"
echo "Current DEFAULT_DEVBOX_USER: $DEFAULT_DEVBOX_USER"

chmod +x "$BASE_TOOLS_DIR/scripts/"*.sh

# Install base packages for Debian
$BASE_TOOLS_DIR/scripts/install-base-pkg-deb.sh

# Install cron and s6 from base-tools scripts
$BASE_TOOLS_DIR/scripts/install-crond.sh
$BASE_TOOLS_DIR/scripts/install-s6.sh
$BASE_TOOLS_DIR/scripts/install-sdk-server.sh

# Configure svc
$BASE_TOOLS_DIR/scripts/configure-svc.sh

# Configure other utilities
$BASE_TOOLS_DIR/scripts/configure-logrotate.sh
$BASE_TOOLS_DIR/scripts/configure-login.sh

# Configure localization (L10N)
$BASE_TOOLS_DIR/scripts/configure-l10n.sh

# Configure user devbox
$BASE_TOOLS_DIR/scripts/configure-user.sh "$DEFAULT_DEVBOX_USER"

# Install user-facing runtime docs (single source from base-tools)
if [ -d "$BASE_TOOLS_DIR/docs" ]; then
    install -d /usr/share/devbox/docs
    cp "$BASE_TOOLS_DIR"/docs/README.s6-user-guide*.md /usr/share/devbox/docs/
    chmod 644 /usr/share/devbox/docs/README.s6-user-guide*.md
else
    echo "No docs directory found in $BASE_TOOLS_DIR; skipping s6 user-guide install"
fi

# Cleanup
$BASE_TOOLS_DIR/scripts/cleanup.sh

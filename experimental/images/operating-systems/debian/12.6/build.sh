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

# Configure svc
$BASE_TOOLS_DIR/scripts/configure-svc.sh

# Configure other utilities
$BASE_TOOLS_DIR/scripts/configure-logrotate.sh
$BASE_TOOLS_DIR/scripts/configure-login.sh

# Configure localization (L10N)
$BASE_TOOLS_DIR/scripts/configure-l10n.sh

# Configure user devbox
$BASE_TOOLS_DIR/scripts/configure-user.sh "$DEFAULT_DEVBOX_USER"

# Cleanup
$BASE_TOOLS_DIR/scripts/cleanup.sh
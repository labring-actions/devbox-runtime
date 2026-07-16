#!/usr/bin/env bash
set -euo pipefail

echo "Current BASE_TOOLS_DIR: $BASE_TOOLS_DIR"
echo "Current L10N: $L10N"
echo "Current ARCH: $ARCH"
echo "Current DEFAULT_DEVBOX_USER: $DEFAULT_DEVBOX_USER"

chmod +x "$BASE_TOOLS_DIR/scripts/"*.sh

# Install base packages for the Alpine/APK family.
"$BASE_TOOLS_DIR/scripts/install-base-pkg-apk.sh"

# Install cron, s6, and the SDK server from the shared tooling scripts.
"$BASE_TOOLS_DIR/scripts/install-crond.sh"
"$BASE_TOOLS_DIR/scripts/install-s6.sh"
"$BASE_TOOLS_DIR/scripts/install-sdk-server.sh"

# Configure svc.
"$BASE_TOOLS_DIR/scripts/configure-svc.sh"

# Product-provided startup scripts can remain active for the DevBox lifetime
# (for example, while serving VS Code Web). Core services must not wait for
# that startup oneshot to exit before they are allowed to run.
rm -f \
    /etc/s6-overlay/s6-rc.d/sshd/dependencies.d/startup \
    /etc/s6-overlay/s6-rc.d/crond/dependencies.d/startup

# Configure other utilities.
"$BASE_TOOLS_DIR/scripts/configure-logrotate.sh"
"$BASE_TOOLS_DIR/scripts/configure-login.sh"

# Configure localization (L10N).
"$BASE_TOOLS_DIR/scripts/configure-l10n.sh"

# Configure user devbox.
"$BASE_TOOLS_DIR/scripts/configure-user.sh" "$DEFAULT_DEVBOX_USER"

# Install user-facing runtime docs (single source from the shared tooling bundle).
if [ -d "$BASE_TOOLS_DIR/docs" ]; then
    install -d /usr/share/devbox/docs
    cp "$BASE_TOOLS_DIR"/docs/README.s6-user-guide*.md /usr/share/devbox/docs/
    chmod 644 /usr/share/devbox/docs/README.s6-user-guide*.md
else
    echo "No docs directory found in $BASE_TOOLS_DIR; skipping s6 user-guide install"
fi

# Cleanup.
"$BASE_TOOLS_DIR/scripts/cleanup.sh"

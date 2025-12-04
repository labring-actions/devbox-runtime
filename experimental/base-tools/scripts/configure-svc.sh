#!/usr/bin/env bash
set -euo pipefail
SOURCE_DIR=$(dirname "$(readlink -f "${BASH_SOURCE[0]}")")
chmod +x $SOURCE_DIR/svc/*.sh
# Important: s6 must be configured before other services that depend on it
$SOURCE_DIR/svc/configure-s6.sh

# Configure pre-rc-init hook FIRST
# This hook runs BEFORE s6-rc compilation, allowing us to disable services
# based on DEVBOX_ENV environment variable
$SOURCE_DIR/svc/configure-pre-rc-init.sh

# Configure individual services
$SOURCE_DIR/svc/configure-startup.sh
$SOURCE_DIR/svc/configure-sshd.sh
$SOURCE_DIR/svc/configure-crond.sh
$SOURCE_DIR/svc/configure-entrypoint.sh
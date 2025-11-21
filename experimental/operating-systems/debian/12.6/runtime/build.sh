#!/usr/bin/env bash
set -euo pipefail
export CONFIGURE_TOOLS_DIR=${CONFIGURE_TOOLS_DIR:-/opt/configure-tools}
$CONFIGURE_TOOLS_DIR/scripts/configure-user.sh
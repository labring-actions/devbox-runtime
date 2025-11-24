#!/usr/bin/env bash
set -euo pipefail
export CONFIGURE_TOOLS_DIR=${CONFIGURE_TOOLS_DIR:-/opt/configure-tools}
$CONFIGURE_TOOLS_DIR/scripts/configure-user.sh
# Apply China Network apt sources patch if enabled
if [ "${CN_PATCH_ENABLED:-false}" = "true" ]; then
  echo "Applying China Network apt sources patch"
  $CONFIGURE_TOOLS_DIR/scripts/configure-cn.sh
else
  echo "China Network apt sources patch not enabled, skipping"
fi
#!/usr/bin/env bash
set -euo pipefail
export CONFIGURE_TOOLS_DIR=${CONFIGURE_TOOLS_DIR:-/opt/configure-tools}
export CN_PATCH_ENABLED=${CN_PATCH_ENABLED:-false}

$CONFIGURE_TOOLS_DIR/scripts/configure-user.sh
# Apply China Network apt sources patch if enabled
echo "CN_PATCH_ENABLED is set to '${CN_PATCH_ENABLED}'"
if [ "${CN_PATCH_ENABLED}" = "true" ]; then
  echo "Applying China Network apt sources patch"
  $CONFIGURE_TOOLS_DIR/scripts/configure-cn.sh
else
  echo "China Network apt sources patch not enabled, skipping"
fi

# Configure locale to en_US.UTF-8
$CONFIGURE_TOOLS_DIR/scripts/configure-locale-en.sh
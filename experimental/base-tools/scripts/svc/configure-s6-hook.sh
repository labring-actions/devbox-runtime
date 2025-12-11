#!/usr/bin/env bash
# ============================================================================
# configure-pre-rc-init.sh
#
# Configure the pre-rc-init hook script.
# The S6_STAGE2_HOOK environment variable is set in the Dockerfile.
# ============================================================================

set -euo pipefail

BASE_TOOLS_DIR=${BASE_TOOLS_DIR:-/opt/base-tools}
S6_HOOK_DIR=/etc/s6-overlay-hook
mkdir -p "$S6_HOOK_DIR"

# Configure pre-rc-init hook
PRE_RC_INIT_HOOK_DIR="$S6_HOOK_DIR/pre-rc-init.d"
mkdir -p "$PRE_RC_INIT_HOOK_DIR"
# Copy the hook script to the appropriate location
cp "$BASE_TOOLS_DIR/scripts/svc/pre-rc-init.sh" "$PRE_RC_INIT_HOOK_DIR/pre-rc-init.sh"
cp "$BASE_TOOLS_DIR/scripts/svc/services.conf" "$PRE_RC_INIT_HOOK_DIR/services.conf"

PRE_RC_INIT_HOOK_SCRIPT="$PRE_RC_INIT_HOOK_DIR/pre-rc-init.sh"
echo "Configuring pre-rc-init hook..." >&2

# Ensure hook script is executable
chmod 755 "$PRE_RC_INIT_HOOK_SCRIPT"

# Note: S6_STAGE2_HOOK is set via ENV in Dockerfile:
#   ENV S6_STAGE2_HOOK=/etc/s6-overlay-hook/pre-rc-init.d/pre-rc-init.sh
# This is the most reliable way to pass env vars to s6-overlay.

echo "PRE_RC_INIT_HOOK script: $PRE_RC_INIT_HOOK_SCRIPT" >&2
echo "  S6_STAGE2_HOOK should be set in Dockerfile" >&2
echo "pre-rc-init hook configured successfully." >&2
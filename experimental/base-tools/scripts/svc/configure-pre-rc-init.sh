#!/usr/bin/env bash
# ============================================================================
# configure-pre-rc-init.sh
#
# Configure the pre-rc-init hook script.
# The S6_STAGE2_HOOK environment variable is set in the Dockerfile.
# ============================================================================

set -euo pipefail

BASE_TOOLS_DIR=${BASE_TOOLS_DIR:-/opt/base-tools}
HOOK_SCRIPT="$BASE_TOOLS_DIR/scripts/svc/pre-rc-init.sh"

echo "Configuring pre-rc-init hook..." >&2

# Ensure hook script is executable
chmod 755 "$HOOK_SCRIPT"

# Note: S6_STAGE2_HOOK is set via ENV in Dockerfile:
#   ENV S6_STAGE2_HOOK=/opt/base-tools/scripts/svc/pre-rc-init.sh
# This is the most reliable way to pass env vars to s6-overlay.

echo "  Hook script: $HOOK_SCRIPT" >&2
echo "  S6_STAGE2_HOOK should be set in Dockerfile" >&2
echo "pre-rc-init hook configured successfully." >&2
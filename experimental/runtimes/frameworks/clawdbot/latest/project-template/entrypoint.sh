#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR=$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)

node "$SCRIPT_DIR/auto-approve.js" &
exec clawdbot gateway --allow-unconfigured --bind lan

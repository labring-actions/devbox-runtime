#!/usr/bin/env bash
set -euo pipefail
# Source some common functions and variables
BASE_TOOLS_DIR=${BASE_TOOLS_DIR:-/opt/base-tools}
ROOT_DIR=$BASE_TOOLS_DIR/scripts/svc
source $ROOT_DIR/common.sh
# Dynamically (re)create s6-rc.d service definitions if missing
mkdir -p "$S6_DIR"
# user bundle contents
mkdir -p "$S6_DIR/user/contents.d"
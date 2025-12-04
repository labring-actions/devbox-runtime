i#!/usr/bin/env bash
set -euo pipefail

SOURCE_DIR=$(dirname "$(readlink -f "${BASH_SOURCE[0]}")")
chmod +x "$SOURCE_DIR/"*.sh
# configure debian source list
"$SOURCE_DIR/configure-deb-source.sh"
# configure locale
"$SOURCE_DIR/configure-locale.sh"
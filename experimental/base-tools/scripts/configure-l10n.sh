#!/usr/bin/env bash
set -euo pipefail

L10N=${L10N:-en_US}
SOURCE_DIR=$(dirname "$(readlink -f "${BASH_SOURCE[0]}")")
echo "Current L10N is set to: $L10N"
if [ -f "$SOURCE_DIR/$L10N/configure.sh" ]; then
  echo "Configuring locale for L10N=$L10N"
  chmod +x "$SOURCE_DIR/$L10N/"*.sh 
  "$SOURCE_DIR/$L10N/configure.sh"
else
  echo "No configuration script found for L10N=$L10N, skipping locale configuration."
fi
#!/usr/bin/env bash
set -euo pipefail
if [ -n "${SEALOS_DEVBOX_NAME:-}" ]; then
	echo "${SEALOS_DEVBOX_NAME}" > /etc/hostname
	chmod 644 /etc/hostname
fi
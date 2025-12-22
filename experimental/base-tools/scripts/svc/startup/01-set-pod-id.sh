#!/usr/bin/env bash
set -euo pipefail
mkdir -p /usr/start
if [ -n "${SEALOS_DEVBOX_POD_UID:-}" ]; then
	echo "${SEALOS_DEVBOX_POD_UID}" > /usr/start/pod_id
	chmod 644 /usr/start/pod_id
fi
#!/bin/bash

# Setup script that runs once at container startup
if [ ! -z "${SEALOS_DEVBOX_NAME}" ]; then
    echo "${SEALOS_DEVBOX_NAME}">/etc/hostname
fi

echo "${SEALOS_DEVBOX_POD_UID}">/usr/start/pod_id

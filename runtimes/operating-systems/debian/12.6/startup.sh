#!/bin/bash

if [ ! -z "${SEALOS_DEVBOX_NAME}" ]; then
    echo "${SEALOS_DEVBOX_NAME}">/etc/hostname
fi

echo "${SEALOS_DEVBOX_POD_UID}">/usr/start/pod_id
# Start the SSH daemon
/usr/sbin/sshd
sleep infinity

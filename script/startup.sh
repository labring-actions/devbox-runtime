#!/bin/bash

# Define the password file location
PASSWORD_FILE="/usr/start/user_password.txt"

# Check if the password file exists
if [ ! -f "${PASSWORD_FILE}" ]; then
    # If the password file doesn't exist, check if USER_PASSWORD is already set
    if [ -z "${SEALOS_DEVBOX_PASSWORD}" ]; then
        # If USER_PASSWORD is not set, generate a random 8-character password
        SEALOS_DEVBOX_PASSWORD=$(< /dev/urandom tr -dc A-Za-z0-9 | head -c8)
    fi
    # Save the generated or existing USER_PASSWORD to the password file
    touch "${PASSWORD_FILE}"
    # Set the password for the 'sealos' user
    echo "sealos:${SEALOS_DEVBOX_PASSWORD}" | sudo chpasswd
    # Display the password for logging purposes (optional)
    echo "SEALOS_DEVBOX_PASSWORD=${SEALOS_DEVBOX_PASSWORD}"
fi

if [ -f /usr/start/.ssh/id.pub ]; then
    public_key=$(cat /usr/start/.ssh/id.pub)
    if ! grep -qF "$public_key" /home/sealos/.ssh/authorized_keys 2>/dev/null; then
        mkdir -p /home/sealos/.ssh 
        echo "$public_key" >> /home/sealos/.ssh/authorized_keys
        echo "Public key successfully added to authorized_keys"
    fi
fi

if [ ! -z "${SEALOS_DEVBOX_NAME}" ]; then
    echo "${SEALOS_DEVBOX_NAME}">/etc/hostname
fi 

echo "${SEALOS_DEVBOX_POD_UID}">/usr/start/pod_id
# Start the SSH daemon
/usr/sbin/sshd
sleep infinity 
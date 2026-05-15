#!/usr/bin/env bash
set -euo pipefail

DEFAULT_USER=${1:-devbox}
ADMIN_GROUP=sudo
# Add user devbox
if id -u "$DEFAULT_USER" &>/dev/null; then
    echo "User $DEFAULT_USER already exists"
    exit 0
fi
if [ "$DEFAULT_USER" = "root" ]; then
    echo "Default user cannot be root"
    exit 1
fi
# By default, set shell to bash if available
if [ -f /bin/bash ]; then
    SHELL_PATH=/bin/bash
elif [ -f /usr/bin/bash ]; then
    SHELL_PATH=/usr/bin/bash
else
    SHELL_PATH=/bin/sh
fi
useradd -m -s "$SHELL_PATH" "$DEFAULT_USER"
# Add user devbox to the distro's admin group and sudoers with NOPASSWD
if ! getent group "$ADMIN_GROUP" >/dev/null 2>&1; then
    if getent group wheel >/dev/null 2>&1; then
        ADMIN_GROUP=wheel
    else
        groupadd "$ADMIN_GROUP"
    fi
fi
usermod -aG "$ADMIN_GROUP" "$DEFAULT_USER"
echo "$DEFAULT_USER ALL=(ALL) NOPASSWD: ALL" >> /etc/sudoers
# Change the password of user devbox
# The password is randomly generated and not logged or stored for security reasons.
# SSH key-based authentication is required, as password authentication is disabled in sshd_config.
PASS=$(openssl rand -base64 16) && echo "$DEFAULT_USER:$PASS" | chpasswd
# Change the home directory permissions
chmod -R 770 "/home/$DEFAULT_USER/"
# Create SSH directory for user devbox
mkdir -p "/home/$DEFAULT_USER/.ssh" && chmod -R 700 "/home/$DEFAULT_USER/.ssh"
# Change ownership of the home directory
chown -R "$DEFAULT_USER:$DEFAULT_USER" "/home/$DEFAULT_USER/"

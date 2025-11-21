#!/usr/bin/env bash
set -euo pipefail

# Add user devbox
useradd -m -s /bin/bash devbox && usermod -aG sudo devbox && echo 'devbox ALL=(ALL) NOPASSWD: ALL' >> /etc/sudoers
# Change the password of user devbox
PASS=$(openssl rand -base64 16) && echo "devbox:$PASS" | chpasswd
# Change the home directory ownership
chown -R devbox:devbox /home/devbox/ && chmod -R 770 /home/devbox/
# Create SSH directory for user devbox
mkdir -p /home/devbox/.ssh && chmod -R 700 /home/devbox/.ssh && chown -R devbox:devbox /home/devbox/.ssh
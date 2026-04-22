#!/usr/bin/env bash
set -euo pipefail
# Remove apt cache to reduce image size
apt-get clean && rm -rf /var/lib/apt/lists/*

# Clear bash history
rm -rf /root/.bash_history

# Remove log files and temporary files
find /var/log -type f -delete
find /tmp -type f -delete
find /var/tmp -type f -delete
#!/usr/bin/env bash
set -euo pipefail

# Remove package manager caches to reduce image size
if command -v apt-get >/dev/null 2>&1; then
    apt-get clean
    rm -rf /var/lib/apt/lists/*
fi
if command -v dnf >/dev/null 2>&1; then
    dnf clean all
    rm -rf /var/cache/dnf
elif command -v yum >/dev/null 2>&1; then
    yum clean all
    rm -rf /var/cache/yum
fi

# Clear bash history
rm -rf /root/.bash_history

# Remove log files and temporary files
find /var/log -type f -delete
find /tmp -type f -delete
find /var/tmp -type f -delete

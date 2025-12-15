#!/usr/bin/env bash
set -euo pipefail

# Install nginx
apt-get update && \
    apt-get install -y nginx && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*

echo "Nginx 1.22.1 installed successfully"


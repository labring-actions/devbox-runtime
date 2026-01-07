#!/usr/bin/env bash
set -euo pipefail

# Install nginx for serving static assets
apt-get update && \
    apt-get install -y nginx && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*

#!/usr/bin/env bash
set -euo pipefail

# Install gcc, g++, and make
# These packages are available in Debian repositories
apt-get update && \
    apt-get install -y gcc g++ make && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*


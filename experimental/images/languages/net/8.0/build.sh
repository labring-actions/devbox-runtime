#!/usr/bin/env bash
set -euo pipefail

# Download and install Microsoft package configuration
# Note: wget is already installed in images/debian-12.6 via install-base-pkg-deb.sh
wget https://packages.microsoft.com/config/debian/12/packages-microsoft-prod.deb -O packages-microsoft-prod.deb && \
    dpkg -i packages-microsoft-prod.deb && \
    rm -f packages-microsoft-prod.deb

# Update package list and install .NET SDK 8.0
apt-get update && \
    apt-get install -y dotnet-sdk-8.0 && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*


#!/usr/bin/env bash
set -euo pipefail

# Install Hugo CLI
# Note: curl is already installed in images/debian-12.6 via install-base-pkg-deb.sh
curl -LO https://github.com/gohugoio/hugo/releases/download/v0.135.0/hugo_extended_0.135.0_linux-amd64.tar.gz && \
    tar -xvzf hugo_extended_0.135.0_linux-amd64.tar.gz && \
    mv hugo /usr/local/bin/ && \
    chmod +x /usr/local/bin/hugo && \
    rm -f README.md LICENSE hugo_extended_0.135.0_linux-amd64.tar.gz

echo "Hugo v0.135.0 CLI installed successfully"


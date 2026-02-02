#!/usr/bin/env bash
set -euo pipefail

arch="$(dpkg --print-architecture)"
apt-get update && \
    apt-get install -y ca-certificates curl && \
    curl -fsSL https://dot.net/v1/dotnet-install.sh -o /tmp/dotnet-install.sh && \
    bash /tmp/dotnet-install.sh --channel 8.0 --install-dir /usr/share/dotnet --architecture "$arch" && \
    ln -sf /usr/share/dotnet/dotnet /usr/bin/dotnet && \
    install -d /etc/profile.d && \
    printf '%s\n' 'export DOTNET_ROOT=/usr/share/dotnet' 'export PATH="$PATH:/usr/share/dotnet"' > /etc/profile.d/dotnet.sh && \
    rm -f /tmp/dotnet-install.sh && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*

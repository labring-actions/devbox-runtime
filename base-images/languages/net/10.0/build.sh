#!/usr/bin/env bash
set -euo pipefail

L10N=${L10N:-en_US}
DEFAULT_DEVBOX_USER=${DEFAULT_DEVBOX_USER:-devbox}

configure_nuget_source() {
    local user_home="$1"
    local owner="${2:-}"
    local config_dir="$user_home/.nuget/NuGet"
    local config_file="$config_dir/NuGet.Config"

    mkdir -p "$config_dir"
    cat > "$config_file" <<'EOF'
<?xml version="1.0" encoding="utf-8"?>
<configuration>
  <packageSources>
    <clear />
    <add key="nuget-azure-cn" value="https://nuget.cdn.azure.cn/v3/index.json" />
    <add key="tencent-nuget" value="https://mirrors.cloud.tencent.com/nuget/" />
  </packageSources>
</configuration>
EOF
    chmod 0644 "$config_file"

    if [ -n "$owner" ]; then
        chown -R "$owner:$owner" "$user_home/.nuget" || true
    fi
}

arch="$(dpkg --print-architecture)"
apt-get update
apt-get install -y ca-certificates curl libicu72
curl -fsSL https://dot.net/v1/dotnet-install.sh -o /tmp/dotnet-install.sh
bash /tmp/dotnet-install.sh --channel 10.0 --install-dir /usr/share/dotnet --architecture "$arch"
ln -sf /usr/share/dotnet/dotnet /usr/bin/dotnet
install -d /etc/profile.d
# shellcheck disable=SC2016
printf '%s\n' 'export DOTNET_ROOT=/usr/share/dotnet' 'export PATH="$PATH:/usr/share/dotnet"' > /etc/profile.d/dotnet.sh
rm -f /tmp/dotnet-install.sh
apt-get clean
rm -rf /var/lib/apt/lists/*

if [ "$L10N" = "zh_CN" ]; then
    configure_nuget_source /root

    DEVBOX_HOME="$(getent passwd "$DEFAULT_DEVBOX_USER" | cut -d: -f6 || true)"
    if [ -z "$DEVBOX_HOME" ]; then
        DEVBOX_HOME="/home/${DEFAULT_DEVBOX_USER}"
    fi
    configure_nuget_source "$DEVBOX_HOME" "$DEFAULT_DEVBOX_USER"
fi

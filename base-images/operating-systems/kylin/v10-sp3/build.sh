#!/usr/bin/env bash
set -euo pipefail

echo "Current BASE_TOOLS_DIR: $BASE_TOOLS_DIR"
echo "Current L10N: $L10N"
echo "Current ARCH: $ARCH"
echo "Current DEFAULT_DEVBOX_USER: $DEFAULT_DEVBOX_USER"

chmod +x "$BASE_TOOLS_DIR/scripts/"*.sh

# Install base packages for Kylin/RPM family
"$BASE_TOOLS_DIR/scripts/install-base-pkg-rpm.sh"

# Kylin V10 SP3 ships glibc 2.28, which meets the VS Code Server Linux
# prerequisite, but its GCC 7 libstdc++ only provides GLIBCXX_3.4.24.
# Install an Anolis 8 libstdc++ build with GLIBCXX_3.4.25 while keeping the
# system glibc unchanged.
tmp_dir="$(mktemp -d)"
trap 'rm -rf "$tmp_dir"' EXIT
case "${ARCH:-amd64}" in
    amd64)
        rpm_arch=x86_64
        libstdcxx_rpm_sha256="1cdcd031a575525b43c2787f750a855228433e982a7ddffc9d12d01f73f5ca68"
        ;;
    arm64)
        rpm_arch=aarch64
        libstdcxx_rpm_sha256="412632fe27bf8ab264b8b4544a466225adc59bcb7cc30dce2f08f9630073b18c"
        ;;
    *)
        echo "Unsupported ARCH for Kylin libstdc++ compatibility package: ${ARCH:-}" >&2
        exit 1
        ;;
esac
libstdcxx_rpm_url="https://mirrors.openanolis.cn/anolis/8/BaseOS/${rpm_arch}/os/Packages/libstdc++-8.5.0-24.0.1.an8.${rpm_arch}.rpm"
libstdcxx_rpm="$tmp_dir/libstdc++.rpm"
curl -fsSL "$libstdcxx_rpm_url" -o "$libstdcxx_rpm"
echo "$libstdcxx_rpm_sha256  $libstdcxx_rpm" | sha256sum -c -
(
    cd "$tmp_dir"
    rpm2cpio "$libstdcxx_rpm" | cpio -idm --quiet ./usr/lib64/libstdc++.so.6 ./usr/lib64/libstdc++.so.6.0.25
)
install -m 0755 "$tmp_dir/usr/lib64/libstdc++.so.6.0.25" /usr/lib64/libstdc++.so.6.0.25
ln -sf libstdc++.so.6.0.25 /usr/lib64/libstdc++.so.6
ldconfig
if ! grep -ao 'GLIBCXX_3\.4\.25' /usr/lib64/libstdc++.so.6 >/dev/null 2>&1; then
    echo "libstdc++ does not provide GLIBCXX_3.4.25" >&2
    exit 1
fi
rm -rf "$tmp_dir"
trap - EXIT

# Install cron, s6, and the SDK server from the shared tooling scripts
"$BASE_TOOLS_DIR/scripts/install-crond.sh"
"$BASE_TOOLS_DIR/scripts/install-s6.sh"
"$BASE_TOOLS_DIR/scripts/install-sdk-server.sh"

# Configure svc
"$BASE_TOOLS_DIR/scripts/configure-svc.sh"

# Configure other utilities
"$BASE_TOOLS_DIR/scripts/configure-logrotate.sh"
"$BASE_TOOLS_DIR/scripts/configure-login.sh"

# Configure localization (L10N)
"$BASE_TOOLS_DIR/scripts/configure-l10n.sh"

# Configure user devbox
"$BASE_TOOLS_DIR/scripts/configure-user.sh" "$DEFAULT_DEVBOX_USER"

# Install user-facing runtime docs (single source from the shared tooling bundle)
if [ -d "$BASE_TOOLS_DIR/docs" ]; then
    install -d /usr/share/devbox/docs
    cp "$BASE_TOOLS_DIR"/docs/README.s6-user-guide*.md /usr/share/devbox/docs/
    chmod 644 /usr/share/devbox/docs/README.s6-user-guide*.md
else
    echo "No docs directory found in $BASE_TOOLS_DIR; skipping s6 user-guide install"
fi

# Cleanup
"$BASE_TOOLS_DIR/scripts/cleanup.sh"

#!/usr/bin/env bash
set -euo pipefail

if command -v dnf >/dev/null 2>&1; then
    PM=dnf
elif command -v yum >/dev/null 2>&1; then
    PM=yum
else
    echo "Neither dnf nor yum is available" >&2
    exit 1
fi

package_available() {
    "$PM" list --showduplicates "$1" >/dev/null 2>&1
}

LOCALE_PACKAGES=(
    glibc-locale-source
    langpacks-en
)

if package_available glibc-langpack-en; then
    LOCALE_PACKAGES+=(glibc-langpack-en)
else
    LOCALE_PACKAGES+=(glibc-all-langpacks)
fi

if [ "${L10N:-en_US}" = "zh_CN" ]; then
    LOCALE_PACKAGES+=(langpacks-zh_CN)
fi

"$PM" install -y \
    bash \
    busybox \
    ca-certificates \
    cpio \
    cronie \
    curl \
    diffutils \
    findutils \
    git \
    gzip \
    iproute \
    logrotate \
    openssh-clients \
    openssh-server \
    openssl \
    passwd \
    procps-ng \
    shadow \
    sudo \
    tar \
    util-linux \
    vim-enhanced \
    wget \
    which \
    xz \
    "${LOCALE_PACKAGES[@]}"

"$PM" clean all
rm -rf /var/cache/dnf /var/cache/yum

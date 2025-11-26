#!/usr/bin/env bash
set -euo pipefail

S6_OVERLAY_VERSION=${S6_OVERLAY_VERSION:-"3.2.1.0"}
ARCH=${ARCH:?"ARCH environment variable is not set"}
# TODO: verify ARCH is valid, if ARCH is x86_64, use amd64 in the download URL
case "${ARCH}" in
	x86_64|amd64)
		DOWNLOAD_ARCH=x86_64
		;;
	aarch64|arm64)
		DOWNLOAD_ARCH=aarch64
		;;
	armv7|armhf)
		DOWNLOAD_ARCH=armhf
		;;
	*)
		echo "Unsupported ARCH: ${ARCH}" >&2
		echo "Supported values: x86_64, amd64, aarch64, arm64, armv7, armhf" >&2
		exit 1
		;;
esac
wget "https://github.com/just-containers/s6-overlay/releases/download/v${S6_OVERLAY_VERSION}/s6-overlay-noarch.tar.xz" -O /tmp/s6-overlay-noarch.tar.xz
tar -C / -Jxpf /tmp/s6-overlay-noarch.tar.xz
wget "https://github.com/just-containers/s6-overlay/releases/download/v${S6_OVERLAY_VERSION}/s6-overlay-${DOWNLOAD_ARCH}.tar.xz" -O /tmp/s6-overlay-arch.tar.xz
tar -C / -Jxpf /tmp/s6-overlay-arch.tar.xz
rm -rf /tmp/s6-overlay-*.tar.xz
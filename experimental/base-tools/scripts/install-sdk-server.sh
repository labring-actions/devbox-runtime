#!/usr/bin/env bash
set -euo pipefail

DEVBOX_SDK_SERVER_VERSION=${DEVBOX_SDK_SERVER_VERSION:-"0.1.0"}
ARCH=${ARCH:?"ARCH environment variable is not set"}
# TODO: verify ARCH is valid, if ARCH is x86_64, use amd64 in the download URL
case "${ARCH}" in
	x86_64|amd64)
		DOWNLOAD_ARCH=x86_64
		;;
	aarch64|arm64)
		DOWNLOAD_ARCH=aarch64
		;;
	*)
		echo "Unsupported ARCH: ${ARCH}" >&2
		echo "Supported values: x86_64, amd64, aarch64, arm64" >&2
		exit 1
		;;
esac

mkdir -p /usr/sbin
wget "https://github.com/labring/devbox-sdk/releases/download/devbox-sdk-server-v${DEVBOX_SDK_SERVER_VERSION}/devbox-sdk-server-linux-${DOWNLOAD_ARCH}" -O /usr/sbin/devbox-sdk-server
chmod +x /usr/sbin/devbox-sdk-server
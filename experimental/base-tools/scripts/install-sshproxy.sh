#!/usr/bin/env bash
set -euo pipefail

SSHPROXY_VERSION=${SSHPROXY_VERSION:-"v0.0.0-alpha"}
ARCH=${ARCH:?"ARCH environment variable is not set"}
# TODO: verify ARCH is valid, if ARCH is x86_64, use amd64 in the download URL
case "${ARCH}" in
	x86_64|amd64)
		DOWNLOAD_ARCH=amd64
		;;
	aarch64|arm64)
		DOWNLOAD_ARCH=arm64
		;;
	armv7|armhf)
		DOWNLOAD_ARCH=armv7
		;;
	*)
		echo "Unsupported ARCH: ${ARCH}" >&2
		echo "Supported values: x86_64, amd64, aarch64, arm64, armv7, armhf" >&2
		exit 1
		;;
esac
mkdir -p /usr/sbin
wget "https://github.com/dinoallo/devbox-connect/releases/download/${SSHPROXY_VERSION}/sshproxy-linux-${DOWNLOAD_ARCH}" -O /usr/sbin/sshproxy
chmod +x /usr/sbin/sshproxy
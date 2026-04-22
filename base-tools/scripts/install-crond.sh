#!/usr/bin/env bash
set -euo pipefail

SUPERCRONIC_VERSION=${SUPERCRONIC_VERSION:-"v0.2.34"}
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
wget "https://github.com/aptible/supercronic/releases/download/${SUPERCRONIC_VERSION}/supercronic-linux-${DOWNLOAD_ARCH}" -O /usr/sbin/supercronic
chmod +x /usr/sbin/supercronic
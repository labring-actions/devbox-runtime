#!/usr/bin/env bash
set -euo pipefail

TIMEZONE="${TIMEZONE:-${TZ:-Asia/Shanghai}}"
[ -z "$TIMEZONE" ] && { echo "No timezone configured; skipping."; exit 0; }

ZONEINFO_PATH="/usr/share/zoneinfo/$TIMEZONE"
if [ ! -e "$ZONEINFO_PATH" ]; then
  echo "Timezone data not found for $TIMEZONE at $ZONEINFO_PATH; skipping."
  exit 0
fi

ln -sf "$ZONEINFO_PATH" /etc/localtime
echo "$TIMEZONE" > /etc/timezone
echo "Timezone set to $TIMEZONE"

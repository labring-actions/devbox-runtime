#!/usr/bin/env bash
set -euo pipefail

# Currently, we set locale to en_US.UTF-8 even in zh_CN images
LOCALE=en_US.UTF-8

echo "LC_ALL=$LOCALE" >> /etc/environment
echo "$LOCALE UTF-8" >> /etc/locale.gen
echo "LANG=$LOCALE" > /etc/locale.conf

if locale -a 2>/dev/null | grep -Eqi '^(en_US\.utf8|en_US\.UTF-8)$'; then
    echo "$LOCALE already available"
elif command -v locale-gen >/dev/null 2>&1; then
    locale-gen "$LOCALE"
elif command -v localedef >/dev/null 2>&1; then
    localedef -i en_US -f UTF-8 "$LOCALE" || echo "Unable to generate $LOCALE with localedef; continuing"
else
    echo "No locale generator found; continuing"
fi

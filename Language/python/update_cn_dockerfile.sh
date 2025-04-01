#!/bin/bash

DOCKERFILE=$1
echo "DOCKERFILE: $DOCKERFILE"
TMP_DOCKERFILE="${DOCKERFILE}tmp"
cp "$DOCKERFILE" "$TMP_DOCKERFILE"

sed -i '$i\
COPY /OS/debian-ssh/debian.sources /etc/apt/sources.list.d/debian.sources' "$TMP_DOCKERFILE"

sed -i '$i\
RUN pip config set global.index-url https://mirrors.tuna.tsinghua.edu.cn/pypi/web/simple' "$TMP_DOCKERFILE"

sed -i '$i\
USER devbox' "$TMP_DOCKERFILE"

sed -i '$i\
RUN pip config set global.index-url https://mirrors.tuna.tsinghua.edu.cn/pypi/web/simple' "$TMP_DOCKERFILE"

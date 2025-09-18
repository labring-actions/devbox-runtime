#!/bin/bash

DOCKERFILE=$1
echo "DOCKERFILE: $DOCKERFILE"
TMP_DOCKERFILE="${DOCKERFILE}tmp"
cp "$DOCKERFILE" "$TMP_DOCKERFILE"

sed -i '$i\
COPY /OS/debian-ssh/debian.sources /etc/apt/sources.list.d/debian.sources' "$TMP_DOCKERFILE"

sed -i '$i\
RUN echo "export GOPROXY=https://goproxy.cn,direct" >> /home/devbox/.bashrc && echo "export GOPROXY=https://goproxy.cn,direct" >> /root/.bashrc' "$TMP_DOCKERFILE"
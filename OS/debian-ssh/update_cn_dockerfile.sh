#!/bin/bash

DOCKERFILE=$1
echo "DOCKERFILE: $DOCKERFILE"
TMP_DOCKERFILE="${DOCKERFILE}tmp"
cp $DOCKERFILE $TMP_DOCKERFILE 

# 修正sed命令
sed -i '/COPY \/script\/startup.sh \/usr\/start\/startup.sh/a\
RUN apt-get update && apt-get install -y ca-certificates && apt-get clean && rm -rf /var/lib/apt/lists/*' "$TMP_DOCKERFILE"

# 在ca-certificates安装后插入清华源配置
sed -i '/RUN apt-get update && apt-get install -y ca-certificates/a\
COPY /OS/debian-ssh/debian.sources /etc/apt/sources.list.d/debian.sources' "$TMP_DOCKERFILE"

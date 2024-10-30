#!/bin/bash

DOCKERFILE=$1
echo "DOCKERFILE: $DOCKERFILE"
TMP_DOCKERFILE="${DOCKERFILE}tmp"
cp $DOCKERFILE $TMP_DOCKERFILE 

sed -i '$i\
COPY /OS/ubuntu/sources.list /etc/apt/sources.list' "$TMP_DOCKERFILE"
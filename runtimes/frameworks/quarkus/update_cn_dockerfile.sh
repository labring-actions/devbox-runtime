#!/bin/bash

DOCKERFILE=$1
echo "DOCKERFILE: $DOCKERFILE"
TMP_DOCKERFILE="${DOCKERFILE}tmp"
cp "$DOCKERFILE" "$TMP_DOCKERFILE"

sed -i '$i\
COPY /OS/debian-ssh/debian.sources /etc/apt/sources.list.d/debian.sources' "$TMP_DOCKERFILE"

sed -i '$i\
COPY /Language/java/settings.xml /opt/maven/apache-maven-3.8.6/conf/settings.xml' "$TMP_DOCKERFILE"
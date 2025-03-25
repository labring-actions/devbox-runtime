#!/bin/bash

DOCKERFILE=$1
OS_TYPE=${2:-"linux"}
echo "DOCKERFILE: $DOCKERFILE"
TMP_DOCKERFILE="${DOCKERFILE}tmp"
cp "$DOCKERFILE" "$TMP_DOCKERFILE"

# Different sed syntax for macOS vs Linux
if [[ "$OS_TYPE" == "darwin" ]]; then
  # macOS version
  sed -i '' '$i\
COPY /OS/debian-ssh/debian.sources /etc/apt/sources.list.d/debian.sources' "$TMP_DOCKERFILE"

  sed -i '' '$i\
RUN pip config set global.index-url https://mirrors.tuna.tsinghua.edu.cn/pypi/web/simple' "$TMP_DOCKERFILE"

  sed -i '' '$i\
USER devbox' "$TMP_DOCKERFILE"

  sed -i '' '$i\
RUN pip config set global.index-url https://mirrors.tuna.tsinghua.edu.cn/pypi/web/simple' "$TMP_DOCKERFILE"
else
  # Linux version
  sed -i '$i\
COPY /OS/debian-ssh/debian.sources /etc/apt/sources.list.d/debian.sources' "$TMP_DOCKERFILE"

  sed -i '$i\
RUN pip config set global.index-url https://mirrors.tuna.tsinghua.edu.cn/pypi/web/simple' "$TMP_DOCKERFILE"

  sed -i '$i\
USER devbox' "$TMP_DOCKERFILE"

  sed -i '$i\
RUN pip config set global.index-url https://mirrors.tuna.tsinghua.edu.cn/pypi/web/simple' "$TMP_DOCKERFILE"
fi

# Replace original file with modified one
mv "$TMP_DOCKERFILE" "$DOCKERFILE"

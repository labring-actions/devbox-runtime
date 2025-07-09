#!/bin/bash

if [ "$#" -ne 4 ]; then
  echo "Usage: $0 <registry> <username> <build_target> <tag>"
  exit 1
fi

REGISTRY=$1
USERNAME=$2
BUILD_TARGET=$3
TAG=$4

IFS='/' read -ra ADDR <<< "$BUILD_TARGET"
IMAGE_NAME="${ADDR[1]}-${ADDR[2]}"

echo "$REGISTRY/$USERNAME/devbox/$IMAGE_NAME:$TAG"

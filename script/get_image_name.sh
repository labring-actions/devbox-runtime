#!/bin/bash

if [ "$#" -ne 3 ]; then
  echo "Usage: $0 <username> <build_target> <tag>"
  exit 1
fi

USERNAME=$1
BUILD_TARGET=$2
TAG=$3

IFS='/' read -ra ADDR <<< "$BUILD_TARGET"
IMAGE_NAME="${ADDR[1]}-${ADDR[2]}"

echo "ghcr.io/$USERNAME/devbox/$IMAGE_NAME:$TAG"

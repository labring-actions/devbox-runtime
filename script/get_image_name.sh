#!/bin/bash

if [ "$#" -ne 4 ]; then
  echo "Usage: $0 <registry> <namespace> <build_target> <tag>"
  exit 1
fi

REGISTRY=$1
NAMESPACE=$2
BUILD_TARGET=$3
TAG=$4

# 提取镜像标识
IFS='/' read -ra ADDR <<< "$BUILD_TARGET"
IMAGE_NAME="${ADDR[1]}-${ADDR[2]}"

if [[ "$REGISTRY" == ghcr.io* ]]; then
  # ghcr.io 格式
  echo "$REGISTRY/$NAMESPACE/devbox/$IMAGE_NAME:$TAG"
else
  # ACR 格式
  echo "$REGISTRY/$NAMESPACE/$IMAGE_NAME:$TAG"
fi

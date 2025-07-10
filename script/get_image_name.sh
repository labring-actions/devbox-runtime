#!/bin/bash

if [ "$#" -ne 5 ]; then
  echo "Usage: $0 <registry> <namespace> <repo> <build_target> <tag>"
  exit 1
fi

REGISTRY=$1
NAMESPACE=$2
REPO=$3
BUILD_TARGET=$4
TAG=$5

# 判断 registry 类型
if [[ "$REGISTRY" == ghcr.io* ]]; then
  # ghcr.io 格式
  IFS='/' read -ra ADDR <<< "$BUILD_TARGET"
  IMAGE_NAME="${ADDR[1]}-${ADDR[2]}"
  echo "$REGISTRY/$NAMESPACE/devbox/$IMAGE_NAME:$TAG"
else
  # 默认按阿里云 ACR 格式
  echo "$REGISTRY/$NAMESPACE/$REPO:$TAG"
fi

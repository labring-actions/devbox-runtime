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

if [[ "$REGISTRY" == ghcr.io* ]]; then
  # ghcr.io 格式
  IFS='/' read -ra ADDR <<< "$BUILD_TARGET"
  IMAGE_NAME="${ADDR[1]}-${ADDR[2]}"
  echo "$REGISTRY/$NAMESPACE/devbox/$IMAGE_NAME:$TAG"
else
  # ACR 格式，tag 自动拼接镜像标识
  IFS='/' read -ra ADDR <<< "$BUILD_TARGET"
  IMAGE_ID="${ADDR[1]}-${ADDR[2]}"
  echo "$REGISTRY/$NAMESPACE/$REPO:${IMAGE_ID}-$TAG"
fi

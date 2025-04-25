#!/bin/bash

if [ "$#" -ne 1 ]; then
  echo "Usage: $0 <build_target>"
  exit 1
fi

BUILD_TARGET=$1

IFS='/' read -ra ADDR <<< "$BUILD_TARGET"
IMAGE_NAME="${ADDR[1]}-${ADDR[2]}"

# /Framework/angular/v18/Dockerfile => /Framework/angular
# 生成 config.json 的路径
TEMPLATE_REPO_CONFIG_PATH="${ADDR[0]}/${ADDR[1]}/repo.json"
if [ ! -f "$TEMPLATE_REPO_CONFIG_PATH" ]; then
  echo "Error: repo.json file not found at $TEMPLATE_REPO_CONFIG_PATH"
  exit 1
fi
echo $(cat "$TEMPLATE_REPO_CONFIG_PATH")

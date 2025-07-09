#!/bin/bash

build_target=$1
ghcr_image_name=$2
acr_image_name=$3

function build_and_push_images() {
  # 构建并推送ghcr镜像
  echo "Building and pushing ghcr image: $ghcr_image_name"
  docker buildx build --push \
    --file "$build_target" \
    --platform linux/amd64 \
    --tag "$ghcr_image_name" \
    .
  
  # 执行CN补丁
  execute_cn_patch
  
  # 构建并推送阿里云ACR镜像
  echo "Building and pushing ACR image: $acr_image_name"
  docker buildx build --push \
    --file "$build_target" \
    --platform linux/amd64 \
    --tag "$acr_image_name" \
    .
}

function execute_cn_patch() {
  script_dir=$(dirname "$(dirname "$build_target")")
  if [ -f "$script_dir/update_cn_dockerfile.sh" ]; then
    echo "Applying CN patch..."
    bash "$script_dir/update_cn_dockerfile.sh" "$build_target"
  fi
}

# 检查参数数量
if [ "$#" -ne 3 ]; then
  echo "Usage: $0 <build_target> <ghcr_image_name> <acr_image_name>"
  exit 1
fi

build_and_push_images

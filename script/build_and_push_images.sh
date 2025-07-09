#!/bin/bash

build_target=$1
image_name=$2
is_cn=$3

function build_and_push_image() {
  docker buildx build --push \
    --file "$build_target" \
    --platform linux/amd64 \
    --tag "$image_name" \
    .
}

function execute_cn_patch() {
  script_dir=$(dirname "$(dirname "$build_target")")
  bash "$script_dir/update_cn_dockerfile.sh" "$build_target"
}

if [ "$is_cn" == "1" ]; then
  execute_cn_patch
fi

build_and_push_image

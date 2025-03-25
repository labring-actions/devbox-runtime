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
  # Use a compatible approach for both Linux and macOS
  if [[ "$OSTYPE" == "darwin"* ]]; then
    # macOS requires an argument for -i
    bash "$script_dir/update_cn_dockerfile.sh" "$build_target" "darwin"
  else
    # Linux version
    bash "$script_dir/update_cn_dockerfile.sh" "$build_target" "linux"
  fi
}

if [ "$is_cn" -eq 1 ]; then
  echo "executing cn patch"
  execute_cn_patch
fi

build_and_push_image

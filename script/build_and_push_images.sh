#!/bin/bash

# 打印环境变量以进行调试
echo "PARENT_DIRS=$PARENT_DIRS"
echo "DIFF_OUTPUT=$DIFF_OUTPUT"

TAG=$1
echo "TAG=$TAG"

# 将环境变量读取为数组
IFS=',' read -r -a DIFF_OUTPUT_ARRAY <<< "$DIFF_OUTPUT"
IFS=',' read -r -a PARENT_DIRS_ARRAY <<< "$PARENT_DIRS"

# 打印数组内容以进行调试
echo "DIFF_OUTPUT array: ${DIFF_OUTPUT_ARRAY[@]}"
echo "PARENT_DIRS array: ${PARENT_DIRS_ARRAY[@]}"

# 构建并推送每个Docker镜像
for i in "${!DIFF_OUTPUT_ARRAY[@]}"; do
  DOCKERFILE_PATH=${DIFF_OUTPUT_ARRAY[$i]}
  PARENT_DIR=${PARENT_DIRS_ARRAY[$i]}
  IMAGE_NAME="$PARENT_DIR:$TAG"
  echo "Building and pushing image for $DOCKERFILE_PATH with tag $IMAGE_NAME"
  docker buildx build --push \
    --file $DOCKERFILE_PATH \
    --platform linux/amd64\
    --tag "ghcr.io/$USERNAME/devbox/$IMAGE_NAME" \
    .
done

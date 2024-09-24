#!/bin/bash

echo "PARENT_DIRS=$PARENT_DIRS"
echo "DIFF_OUTPUT=$DIFF_OUTPUT"

TAG=$1
CN_TAG=$2

IFS=',' read -r -a DIFF_OUTPUT_ARRAY <<< "$DIFF_OUTPUT"
IFS=',' read -r -a PARENT_DIRS_ARRAY <<< "$PARENT_DIRS"

echo "DIFF_OUTPUT array: ${DIFF_OUTPUT_ARRAY[@]}"
echo "PARENT_DIRS array: ${PARENT_DIRS_ARRAY[@]}"

for i in "${!DIFF_OUTPUT_ARRAY[@]}"; do
  DOCKERFILE_PATH=${DIFF_OUTPUT_ARRAY[$i]}
  parent_path="${DOCKERFILE_PATH%/*}"
  bash "$parent_path/update_cn_dockerfile.sh" $DOCKERFILE_PATH
  IFS='/' read -ra ADDR <<< $DOCKERFILE_PATH
  PARENT_DIR=${PARENT_DIRS_ARRAY[$i]}
  EN_IMAGE_NAME="${ADDR[1]}-$PARENT_DIR:$TAG"


  docker buildx build --push \
    --file $DOCKERFILE_PATH \
    --platform linux/amd64\
    --tag "ghcr.io/$USERNAME/devbox/$EN_IMAGE_NAME" \
    .
  
  CN_IMAGE_NAME="${ADDR[1]}-$PARENT_DIR:$CN_TAG"
  docker buildx build --push \
    --file $DOCKERFILE_PATH"tmp" \
    --platform linux/amd64\
    --tag "ghcr.io/$USERNAME/devbox/$CN_IMAGE_NAME" \
    .

  rm $DOCKERFILE_PATH"tmp"
done

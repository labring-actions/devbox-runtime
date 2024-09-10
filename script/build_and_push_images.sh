#!/bin/bash

echo "PARENT_DIRS=$PARENT_DIRS"
echo "DIFF_OUTPUT=$DIFF_OUTPUT"

TAG=$1
echo "TAG=$TAG"

IFS=',' read -r -a DIFF_OUTPUT_ARRAY <<< "$DIFF_OUTPUT"
IFS=',' read -r -a PARENT_DIRS_ARRAY <<< "$PARENT_DIRS"

echo "DIFF_OUTPUT array: ${DIFF_OUTPUT_ARRAY[@]}"
echo "PARENT_DIRS array: ${PARENT_DIRS_ARRAY[@]}"

for i in "${!DIFF_OUTPUT_ARRAY[@]}"; do
  DOCKERFILE_PATH=${DIFF_OUTPUT_ARRAY[$i]}
  IFS='/' read -ra ADDR <<< $DOCKERFILE_PATH
  PARENT_DIR=${PARENT_DIRS_ARRAY[$i]}
  IMAGE_NAME="${ADDR[1]}-$PARENT_DIR:$TAG"
  echo "Building and pushing image for $DOCKERFILE_PATH with tag $IMAGE_NAME"
  docker buildx build --push \
    --file $DOCKERFILE_PATH \
    --platform linux/amd64\
    --tag "ghcr.io/$USERNAME/devbox/$IMAGE_NAME" \
    .
done

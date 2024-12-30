#!/bin/bash

# Print the input parent directories and difference output
echo "PARENT_DIRS=$PARENT_DIRS"
echo "DIFF_OUTPUT=$DIFF_OUTPUT"

# Get tags from the input parameters
TAG=$1
CN_TAG=$2

# Read the differences and parent directories into arrays
IFS=',' read -r -a DIFF_OUTPUT_ARRAY <<< "$DIFF_OUTPUT"
IFS=',' read -r -a PARENT_DIRS_ARRAY <<< "$PARENT_DIRS"

# Print the contents of the arrays for debugging
echo "DIFF_OUTPUT array: ${DIFF_OUTPUT_ARRAY[@]}"
echo "PARENT_DIRS array: ${PARENT_DIRS_ARRAY[@]}"

# Function to build and push Docker images
build_and_push_image() {
  local dockerfile_path=$1
  local image_name=$2

  docker buildx build --push \
    --file "$dockerfile_path" \
    --platform linux/amd64 \
    --tag "ghcr.io/$USERNAME/devbox/$image_name" \
    .
}

# Iterate over Dockerfile paths
for i in "${!DIFF_OUTPUT_ARRAY[@]}"; do
  DOCKERFILE_PATH=${DIFF_OUTPUT_ARRAY[$i]}
  PARENT_DIR=${PARENT_DIRS_ARRAY[$i]}
  
  # Extract parent path for further use
  parent_path="${DOCKERFILE_PATH%/*}"
  parent_path=$(dirname "$parent_path")

  # Create the English image name
  IFS='/' read -ra ADDR <<< "$DOCKERFILE_PATH"
  EN_IMAGE_NAME="${ADDR[1]}-$PARENT_DIR:$TAG"

  # Build and push the English Docker image
  build_and_push_image "$DOCKERFILE_PATH" "$EN_IMAGE_NAME"

  # Check for the Chinese Dockerfile update script and handle accordingly
  if [ -f "$parent_path/update_cn_dockerfile.sh" ]; then
    bash "$parent_path/update_cn_dockerfile.sh" "$DOCKERFILE_PATH"
    CN_IMAGE_NAME="${ADDR[1]}-$PARENT_DIR:$CN_TAG"

    # Use a temporary Dockerfile for the Chinese image
    TEMP_DOCKERFILE="${DOCKERFILE_PATH}tmp"
    
    # Build and push the Chinese Docker image
    build_and_push_image "$TEMP_DOCKERFILE" "$CN_IMAGE_NAME"

    # Remove the temporary Dockerfile
    rm "$TEMP_DOCKERFILE"
  fi
done
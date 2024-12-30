#!/bin/bash

echo "PARENT_DIRS=$PARENT_DIRS"
echo "DIFF_OUTPUT=$DIFF_OUTPUT"

TAG=$1
CN_TAG=$2

IFS=',' read -r -a DIFF_OUTPUT_ARRAY <<< "$DIFF_OUTPUT"
IFS=',' read -r -a PARENT_DIRS_ARRAY <<< "$PARENT_DIRS"

chmod +x runtimectl

declare -A NAME_MAP PORT_MAP VERSION_MAP

load_mappings() {
  local file=$1
  local -n map=$2
  while IFS='=' read -r key value; do
    map["$key"]="$value"
  done < "$file"
}

load_mappings "configs/name.txt" NAME_MAP
load_mappings "configs/port.txt" PORT_MAP
load_mappings "configs/version.txt" VERSION_MAP

for i in "${!DIFF_OUTPUT_ARRAY[@]}"; do
  DOCKERFILE_PATH=${DIFF_OUTPUT_ARRAY[$i]}
  IFS='/' read -ra ADDR <<< $DOCKERFILE_PATH

  PARENT_DIR=${PARENT_DIRS_ARRAY[$i]}

  if [ "${NAME_MAP[${ADDR[1]}]}" == "none" ]; then
    exit 1
  fi

  YAML_PATH="${DOCKERFILE_PATH%/*}"
  parent_path=$(dirname "$YAML_PATH")

  EN_IMAGE_NAME="${ADDR[1]}-$PARENT_DIR:$TAG"
  if [ -f "$parent_path/update_cn_dockerfile.sh" ]; then
    CN_IMAGE_NAME="${ADDR[1]}-$PARENT_DIR:$CN_TAG"
  else
    CN_IMAGE_NAME="${ADDR[1]}-$PARENT_DIR:$TAG"
  fi

  ./runtimectl gen --kind=${ADDR[0]} --name=${NAME_MAP[${ADDR[1]}]} --version=$PARENT_DIR --image=ghcr.io/$DOCKER_USERNAME/devbox/$EN_IMAGE_NAME
  ./runtimectl gen --kind=${ADDR[0]} --name=${NAME_MAP[${ADDR[1]}]} --version=$PARENT_DIR --image=ghcr.io/$DOCKER_USERNAME/devbox/$CN_IMAGE_NAME --path="config-cn.json" 
done

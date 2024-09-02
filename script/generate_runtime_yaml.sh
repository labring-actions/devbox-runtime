#!/bin/bash

echo "PARENT_DIRS=$PARENT_DIRS"
echo "DIFF_OUTPUT=$DIFF_OUTPUT"

TAG=$1
echo "TAG=$TAG"

IFS=',' read -r -a DIFF_OUTPUT_ARRAY <<< "$DIFF_OUTPUT"
IFS=',' read -r -a PARENT_DIRS_ARRAY <<< "$PARENT_DIRS"

for i in "${!DIFF_OUTPUT_ARRAY[@]}"; do
  DOCKERFILE_PATH=${DIFF_OUTPUT_ARRAY[$i]}
  IFS='/' read -ra ADDR <<< $DOCKERFILE_PATH
  PARENT_DIR=${PARENT_DIRS_ARRAY[$i]}
  IMAGE_NAME="$PARENT_DIR:$TAG"

  YAML_PATH="${DOCKERFILE_PATH%/*}"
  RUNTIME_NAME="${PARENT_DIR//./-}"
  mkdir -p "yaml/${YAML_PATH}"
  output_file="yaml/${YAML_PATH}/runtime-$PARENT_DIR.yaml"
  if [ ! -f "$output_file" ]; then
    touch "$output_file"
  fi
  cat << EOF > "$output_file"
apiVersion: devbox.sealos.io/v1alpha1
kind: Runtime
metadata:
  name: $RUNTIME_NAME
spec:
  title: $PARENT_DIR
  classRef: ${ADDR[1]}
  image: "ghcr.io/$DOCKER_USERNAME/devbox/$IMAGE_NAME"
  description: "$PARENT_DIR"
---
apiVersion: devbox.sealos.io/v1alpha1
kind: RuntimeClass
metadata:
  name: ${ADDR[1]}
spec:
  title: ${ADDR[1]}
  kind: ${ADDR[0]}
  description: "${ADDR[1]}"
EOF
done
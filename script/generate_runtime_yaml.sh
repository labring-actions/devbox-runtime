#!/bin/bash

echo "PARENT_DIRS=$PARENT_DIRS"
echo "DIFF_OUTPUT=$DIFF_OUTPUT"

TAG=$1
echo "TAG=$TAG"

IFS=',' read -r -a DIFF_OUTPUT_ARRAY <<< "$DIFF_OUTPUT"
IFS=',' read -r -a PARENT_DIRS_ARRAY <<< "$PARENT_DIRS"

declare -A NAME_MAP
while IFS='=' read -r key value; do
    NAME_MAP["$key"]="$value"
done < "configs/name.txt" 

for i in "${!DIFF_OUTPUT_ARRAY[@]}"; do
  DOCKERFILE_PATH=${DIFF_OUTPUT_ARRAY[$i]}
  IFS='/' read -ra ADDR <<< $DOCKERFILE_PATH

  PARENT_DIR=${PARENT_DIRS_ARRAY[$i]}
  IMAGE_NAME="${ADDR[1]}-$PARENT_DIR:$TAG"
  
  if [ "${NAME_MAP[${ADDR[1]}]}" == "none" ]; then
    exit 1
  fi

  YAML_PATH="${DOCKERFILE_PATH%/*}"
  mkdir -p "yaml/${YAML_PATH}"
  output_file="yaml/${YAML_PATH}/$PARENT_DIR.yaml"
  if [ ! -f "$output_file" ]; then
    touch "$output_file"
  fi
  cat << EOF > "$output_file"
apiVersion: devbox.sealos.io/v1alpha1
kind: Runtime
metadata:
  name: ${ADDR[1]}-${PARENT_DIR//./-}
  namespace: devbox-system
spec:
  classRef: ${ADDR[1]}
  config:
    image: ghcr.io/$DOCKER_USERNAME/devbox/$IMAGE_NAME
    ports:
      - containerPort: 22
        name: devbox-ssh-port
        protocol: TCP
    user: sealos
    workingDir: /home/sealos/project
    releaseCommand:
      - /bin/bash
      - -c
    releaseArgs:
      - /home/sealos/project/entrypoint.sh
  description: ${ADDR[1]} $PARENT_DIR
  version: "$PARENT_DIR"
---
apiVersion: devbox.sealos.io/v1alpha1
kind: RuntimeClass
metadata:
  name: ${ADDR[1]}
spec:
  title: "${NAME_MAP[${ADDR[1]}]}"
  kind: ${ADDR[0]}
  description: ${ADDR[1]}
EOF
done
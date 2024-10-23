#!/bin/bash

echo "PARENT_DIRS=$PARENT_DIRS"
echo "DIFF_OUTPUT=$DIFF_OUTPUT"

TAG=$1
CN_TAG=$2

IFS=',' read -r -a DIFF_OUTPUT_ARRAY <<< "$DIFF_OUTPUT"
IFS=',' read -r -a PARENT_DIRS_ARRAY <<< "$PARENT_DIRS"

declare -A NAME_MAP
while IFS='=' read -r key value; do
    NAME_MAP["$key"]="$value"
done < "configs/name.txt" 

declare -A PORT_MAP
while IFS='=' read -r key value; do
    PORT_MAP["$key"]="$value"
done < "configs/port.txt" 

declare -A VERSION_MAP
while IFS='=' read -r key value; do
    VERSION_MAP["$key"]="$value"
done < "configs/version.txt" 

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

  mkdir -p "yaml/en/${YAML_PATH}"
  mkdir -p "yaml/cn/${YAML_PATH}"
  en_output_file="yaml/en/${YAML_PATH}/$PARENT_DIR.yaml"
  cn_output_file="yaml/cn/${YAML_PATH}/$PARENT_DIR.yaml"
  if [ ! -f "$en_output_file" ]; then
    touch "$en_output_file"
  fi
  if [ ! -f "$cn_output_file" ]; then
    touch "$cn_output_file"
  fi

  cat << EOF > "$en_output_file"
apiVersion: devbox.sealos.io/v1alpha1
kind: Runtime
metadata:
  name: ${ADDR[1]}-${PARENT_DIR//./-}-$TAG
  namespace: devbox-system
spec:
  classRef: ${ADDR[1]}
  config:
    image: ghcr.io/$DOCKER_USERNAME/devbox/$EN_IMAGE_NAME
    ports:
      - containerPort: 22
        name: devbox-ssh-port
        protocol: TCP
    appPorts:
      - port: ${PORT_MAP[${ADDR[1]}]}
        name: devbox-app-port
        protocol: TCP
    user: devbox
    workingDir: /home/devbox/project
    releaseCommand:
      - /bin/bash
      - -c
    releaseArgs:
      - /home/devbox/project/entrypoint.sh
  description: ${ADDR[1]} $PARENT_DIR
  version: "$PARENT_DIR"
  runtimeVersion: ${VERSION_MAP[${ADDR[1]}]} 
  state: active  
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

  cat << EOF > "$cn_output_file"
apiVersion: devbox.sealos.io/v1alpha1
kind: Runtime
metadata:
  name: ${ADDR[1]}-${PARENT_DIR//./-}-$TAG
  namespace: devbox-system
spec:
  classRef: ${ADDR[1]}
  config:
    image: ghcr.io/$DOCKER_USERNAME/devbox/$CN_IMAGE_NAME
    ports:
      - containerPort: 22
        name: devbox-ssh-port
        protocol: TCP
    appPorts:
      - port: ${PORT_MAP[${ADDR[1]}]}
        name: devbox-app-port
        protocol: TCP
    user: devbox
    workingDir: /home/devbox/project
    releaseCommand:
      - /bin/bash
      - -c
    releaseArgs:
      - /home/devbox/project/entrypoint.sh
  description: ${ADDR[1]} $PARENT_DIR
  version: "$PARENT_DIR"
  runtimeVersion: ${VERSION_MAP[${ADDR[1]}]}
  state: active  
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

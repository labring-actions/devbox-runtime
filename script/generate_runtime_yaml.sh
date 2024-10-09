#!/bin/bash

# Define tags from input parameters
TAG=$1
CN_TAG=$2

# Read the Dockerfile differences and parent directories into arrays
IFS=',' read -r -a DIFF_OUTPUT_ARRAY <<< "$DIFF_OUTPUT"
IFS=',' read -r -a PARENT_DIRS_ARRAY <<< "$PARENT_DIRS"

# Load name and port mappings into associative arrays
declare -A NAME_MAP PORT_MAP

# Function to load mappings from a config file into an associative array
load_mappings() {
  local file=$1
  local -n map=$2
  while IFS='=' read -r key value; do
    map["$key"]="$value"
  done < "$file"
}

# Load the name and port mappings
load_mappings "configs/name.txt" NAME_MAP
load_mappings "configs/port.txt" PORT_MAP

# Create YAML output directory structure
mkdir -p yaml/en
mkdir -p yaml/cn

# Function to generate YAML configuration and write it to a file
generate_yaml() {
  local output_file=$1
  local image_name=$2
  local parent_dir=$3
  local kind=$4
  local runtime=$5
   # remaining arguments are passed as an array

  cat << EOF > "$output_file"
apiVersion: devbox.sealos.io/v1alpha1
kind: Runtime
metadata:
  name: $runtime-${parent_dir//./-}
  namespace: devbox-system
spec:
  classRef: $runtime
  config:
    image: ghcr.io/$DOCKER_USERNAME/devbox/$image_name
    ports:
      - containerPort: 22
        name: devbox-ssh-port
        protocol: TCP
    appPorts:
      - port: ${PORT_MAP[$runtime]}
        name: devbox-app-port
        protocol: TCP
    user: sealos
    workingDir: /home/sealos/project
    releaseCommand:
      - /bin/bash
      - -c
    releaseArgs:
      - /home/sealos/project/entrypoint.sh
  description: $runtime $parent_dir
  version: "$parent_dir"
---
apiVersion: devbox.sealos.io/v1alpha1
kind: RuntimeClass
metadata:
  name: $runtime
spec:
  title: "${NAME_MAP[$runtime]}"
  kind: $kind
  description: $runtime
EOF
}

# Iterate over the changed Dockerfiles
for i in "${!DIFF_OUTPUT_ARRAY[@]}"; do
  DOCKERFILE_PATH=${DIFF_OUTPUT_ARRAY[$i]}
  IFS='/' read -ra ADDR <<< "$DOCKERFILE_PATH"
  PARENT_DIR=${PARENT_DIRS_ARRAY[$i]}

  # Check if the name is mapped to "none"
  if [[ "${NAME_MAP[${ADDR[1]}]}" == "none" ]]; then
    exit 1
  fi

  # Define paths for YAML files and the image names
  YAML_PATH="${DOCKERFILE_PATH%/*}"
  EN_IMAGE_NAME="${ADDR[1]}-$PARENT_DIR:$TAG"
  CN_IMAGE_NAME="${ADDR[1]}-$PARENT_DIR:$CN_TAG"

  # Check if update_cn_dockerfile.sh exists to decide CN image name
  if [ -f "$(dirname "$DOCKERFILE_PATH")/update_cn_dockerfile.sh" ]; then
    CN_IMAGE_NAME="${ADDR[1]}-$PARENT_DIR:$CN_TAG"
  else
    CN_IMAGE_NAME="${ADDR[1]}-$PARENT_DIR:$TAG"
  fi

  # Define output files
  en_output_file="yaml/en/${YAML_PATH}/$PARENT_DIR.yaml"
  cn_output_file="yaml/cn/${YAML_PATH}/$PARENT_DIR.yaml"

  # Create the output files if they don’t exist
  if [ ! -f "$en_output_file" ]; then
    touch "$en_output_file"
  fi
  if [ ! -f "$cn_output_file" ]; then
    touch "$cn_output_file"
  fi

  # Generate and write the English and Chinese YAML configurations
  generate_yaml "$en_output_file" "$EN_IMAGE_NAME" "$PARENT_DIR" "${ADDR[0]}" "${ADDR[1]}"
  generate_yaml "$cn_output_file" "$CN_IMAGE_NAME" "$PARENT_DIR" "${ADDR[0]}" "${ADDR[1]}"
done
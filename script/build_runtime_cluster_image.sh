#!/bin/bash

RUNTIME_PATH=$1
RUNTIME_NAME=$2
CLUSTER_IMAGE_NAME=$3

echo "RUNTIME_PATH: $RUNTIME_PATH"
echo "RUNTIME_NAME: $RUNTIME_NAME"
echo "CLUSTER_IMAGE_NAME: $CLUSTER_IMAGE_NAME"

mkdir -p deploy/$RUNTIME_NAME/manifests
cp $RUNTIME_PATH deploy/$RUNTIME_NAME/manifests/runtime.yaml
cp deploy/demo/Kubefile deploy/$RUNTIME_NAME/

cd deploy/$RUNTIME_NAME

sealos build -t $CLUSTER_IMAGE_NAME .

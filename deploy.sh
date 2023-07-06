#!/bin/bash
set -x trace

SCRIPT_DIR=$( cd -- "$( dirname -- "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )
. "${SCRIPT_DIR}/init.sh"


function cluster_exists(){
    k3d cluster list | grep -q "$API_CLUSTER_NAME"
}

function create_cluster(){
  echo "Creating cluster..."
  k3d cluster create "$API_CLUSTER_NAME" \
    --api-port 6550 \
    --servers 1 \
    --agents 1 \
    --port "${API_HTTP_PORT}:80@loadbalancer" \
    --wait
}

function write_kube_config() {
  echo "Writing kube configuration file..."
  k3d kubeconfig get "$API_CLUSTER_NAME" > "$API_CLUSTER_CONFIG_FILE"
  chmod 600 "$API_CLUSTER_CONFIG_FILE"
}

function build_and_import_image(){
  docker build -t "$api_image" "${SCRIPT_DIR}/api"
  k3d image import -c "$API_CLUSTER_NAME" "$api_image"
}

function namespace_exists(){
  kubectl get namespace | grep -q "$API_CLUSTER_NAMESPACE"
}

if ! cluster_exists; then
  create_cluster
fi

write_kube_config

api_image="${API_IMAGE_NAME}:${API_IMAGE_TAG}"
build_and_import_image
if ! namespace_exists; then
  kubectl create namespace "$API_CLUSTER_NAMESPACE"
fi

helm upgrade --debug \
  --install sample-api "${SCRIPT_DIR}/api/chart" \
  --namespace "$API_CLUSTER_NAMESPACE" \
  --set app.image="$api_image" \
  --set app.production="$PRODUCTION"

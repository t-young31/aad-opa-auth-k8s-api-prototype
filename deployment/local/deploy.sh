#!/bin/bash
#set -x trace

SCRIPT_DIR=$( cd -- "$( dirname -- "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )
. "${SCRIPT_DIR}/../../init.sh"

function cluster_exists(){
    k3d cluster list | grep -q "$CLUSTER_NAME"
}

function create_cluster(){
  echo "Creating cluster..."
  k3d cluster create "$CLUSTER_NAME" \
    --api-port "${CLUSTER_API_PORT}" \
    --servers 1 \
    --agents 1 \
    --port "${API_HTTPS_PORT}:443@loadbalancer" \
    --volume "$(pwd)/api/src:$API_SRC_DIRECTORY@all" \
    --wait
}

function write_kube_config() {
  echo "Writing kube configuration file..."
  k3d kubeconfig get "$CLUSTER_NAME" > "$CLUSTER_CONFIG_FILE"
  # Make the config file read/writable to the current user
  chmod 600 "$CLUSTER_CONFIG_FILE"
}

function namespace_exists(){
  kubectl get namespace | grep -q "$API_CLUSTER_NAMESPACE"
}


if ! cluster_exists; then
  create_cluster
  write_kube_config
else
  echo "Cluster [${CLUSTER_NAME}] exists"
fi

if [ ! -f "$CLUSTER_CONFIG_FILE" ]; then
  error "Must have $CLUSTER_CONFIG_FILE"
fi

if ! namespace_exists; then
  kubectl create namespace "$API_CLUSTER_NAMESPACE"
fi

echo "Core infrastructure ✅"

#!/bin/bash

SCRIPT_DIR=$( cd -- "$( dirname -- "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )
. "${SCRIPT_DIR}/init.sh"


function cluster_exists(){
    k3d cluster list | grep "$API_CLUSTER_NAME" &> /dev/null
}

if ! cluster_exists; then
  echo "Creating cluster..."
  k3d cluster create "$API_CLUSTER_NAME" \
    --api-port 6550 \
    --servers 1 \
    --agents 3 \
    --port 8080:80@loadbalancer \
    --volume "$(pwd)/sample:/src@all" \
    --wait
fi

#!/bin/bash
#set -x trace

SCRIPT_DIR=$( cd -- "$( dirname -- "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )
# shellcheck source=/dev/null
. "${SCRIPT_DIR}/../init.sh"


function namespace_exists(){
  kubectl get namespace | grep -q "$API_CLUSTER_NAMESPACE"
}

function build_and_import_image(){
  docker build -t "$api_image" "${SCRIPT_DIR}/src"
  k3d image import -c "$CLUSTER_NAME" "$api_image"
}

function install_chart(){
  helm upgrade \
    --debug \
    --install sample-api "${SCRIPT_DIR}/chart" \
    --namespace "$API_CLUSTER_NAMESPACE" \
    --set app.image="$api_image" \
    --set app.production="$PRODUCTION"
}

if ! namespace_exists; then
  kubectl create namespace "$API_CLUSTER_NAMESPACE"
fi

api_image="${API_IMAGE_NAME}:${API_IMAGE_TAG}"
build_and_import_image
install_chart

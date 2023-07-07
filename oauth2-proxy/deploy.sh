#!/bin/bash
#set -x trace

SCRIPT_DIR=$( cd -- "$( dirname -- "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )
# shellcheck source=/dev/null
. "${SCRIPT_DIR}/../init.sh"


function namespace_exists(){
  kubectl get namespace | grep -q "$API_CLUSTER_NAMESPACE"
}

function install_chart(){
  helm repo add oauth2-proxy https://oauth2-proxy.github.io/manifests

  helm upgrade \
    --debug \
    --install oauth2-proxy oauth2-proxy/oauth2-proxy \
    --namespace "$API_CLUSTER_NAMESPACE"
}

if ! namespace_exists; then
  kubectl create namespace "$API_CLUSTER_NAMESPACE"
fi

install_chart
"${SCRIPT_DIR}/aad_app_registration/deploy.sh"

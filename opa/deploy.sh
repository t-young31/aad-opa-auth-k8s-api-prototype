#!/bin/bash

SCRIPT_DIR=$( cd -- "$( dirname -- "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )
# shellcheck source=/dev/null
. "${SCRIPT_DIR}/../init.sh"

function install_chart(){
  helm upgrade \
    --debug \
    --install opa "${SCRIPT_DIR}/chart" \
    --namespace "$API_CLUSTER_NAMESPACE"
}

install_chart

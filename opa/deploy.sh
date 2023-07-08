#!/bin/bash

SCRIPT_DIR=$( cd -- "$( dirname -- "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )
. "${SCRIPT_DIR}/../init.sh"

function write_values(){
  cat <<EOF > "${SCRIPT_DIR}/chart/values.yaml"
# Auto generated – edits will be overridden
opa:
  port: 8181
  root_email: $OPA_ROOT_EMAIL
EOF
}

function install_chart(){
  helm upgrade \
    --debug \
    --install opa "${SCRIPT_DIR}/chart" \
    --namespace "$API_CLUSTER_NAMESPACE"
}

write_values
install_chart

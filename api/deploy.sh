#!/bin/bash
#set -x trace

SCRIPT_DIR=$( cd -- "$( dirname -- "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )
. "${SCRIPT_DIR}/../init.sh"

function write_values(){
  cat <<EOF > "${SCRIPT_DIR}/chart/values.yaml"
# Auto generated – edits will be overridden
app:
  domain: ${API_DOMAIN+}
  port: 5000
  image: $API_IMAGE_FULL
  production: $PRODUCTION
  debug: $DEBUG
  src: ${API_SRC_DIRECTORY+x}

nginx:
  port: $API_NGINX_PORT

namespace: $API_CLUSTER_NAMESPACE
EOF
}

function install_chart(){
  helm upgrade \
    --debug \
    --install sample-api "${SCRIPT_DIR}/chart" \
    --namespace "$API_CLUSTER_NAMESPACE"
}

write_values
install_chart

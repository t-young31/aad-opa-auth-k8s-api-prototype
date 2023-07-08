#!/bin/bash
#set -x trace

SCRIPT_DIR=$( cd -- "$( dirname -- "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )
. "${SCRIPT_DIR}/../init.sh"

function build_and_import_image(){
  docker build -t "$api_image" "${SCRIPT_DIR}/src"
  k3d image import -c "$CLUSTER_NAME" "$api_image"
}

function write_values(){
  cat <<EOF > "${SCRIPT_DIR}/chart/values.yaml"
# Auto generated – edits will be overridden
app:
  domain: $API_DOMAIN
  port: 5000
  image: $api_image
  production: $PRODUCTION
  debug: $DEBUG

nginx:
  port: 5001

namespace: $API_CLUSTER_NAMESPACE
EOF
}

function install_chart(){
  helm upgrade \
    --debug \
    --install sample-api "${SCRIPT_DIR}/chart" \
    --namespace "$API_CLUSTER_NAMESPACE"
}

api_image="${API_IMAGE_NAME}:${API_IMAGE_TAG}"
build_and_import_image
write_values
install_chart

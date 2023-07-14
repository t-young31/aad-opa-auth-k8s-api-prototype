#!/bin/bash
#set -x trace

SCRIPT_DIR=$( cd -- "$( dirname -- "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )
# shellcheck source=/dev/null
. "${SCRIPT_DIR}/../../init.sh"

function write_tf_vars(){
  cat <<EOF > "${SCRIPT_DIR}/terraform/terraform.tfvars"
# Auto generated – edits will be overridden
azure_suffix = "$AZURE_SUFFIX"
acr_name = "$AZURE_ACR_NAME"
EOF
}

function write_kube_config(){
  cd "${SCRIPT_DIR}/terraform" || exit
  terraform output -raw kube_config > "${SCRIPT_DIR}/../../${CLUSTER_CONFIG_FILE}"
}

function write_chart_values(){
  cat <<EOF > "${SCRIPT_DIR}/chart/values.yaml"
# Auto generated – edits will be overridden
app:
  https_port: $API_HTTPS_PORT
  namespace: $API_CLUSTER_NAMESPACE
  nginx_port: $API_NGINX_PORT
  domain: $AZURE_DOMAIN
EOF
}

function install_chart(){
  helm upgrade \
    --debug \
    --install azure-front "${SCRIPT_DIR}/chart"
}

function build_api_image(){
  docker buildx build --platform linux/amd64 \
    -t "$API_IMAGE_FULL" \
    "${SCRIPT_DIR}/../../api/src"
}

function push_api_image(){
  az acr login --name "$AZURE_ACR_NAME"
  docker push "$API_IMAGE_FULL"
}

assert_azure_logged_in
write_tf_vars
terraform_apply "${SCRIPT_DIR}/terraform"
(write_kube_config)
create_namespace_if_required "$API_CLUSTER_NAMESPACE"
write_chart_values
install_chart
build_api_image
push_api_image

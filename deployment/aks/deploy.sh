#!/bin/bash
set -x trace

SCRIPT_DIR=$( cd -- "$( dirname -- "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )
# shellcheck source=/dev/null
. "${SCRIPT_DIR}/../../init.sh"

function write_tf_vars(){
  cat <<EOF > "${SCRIPT_DIR}/terraform/terraform.tfvars"
# Auto generated – edits will be overridden
azure_suffix = "$AZURE_SUFFIX"
acr_name = "$AZURE_ACR_NAME"
domain_label = "$domain_label"
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

acme_email: $AZURE_ACME_EMAIL
EOF
}

function install_chart(){
  helm upgrade \
    --debug \
    --namespace "$API_CLUSTER_NAMESPACE" \
    --install aks-setup "${SCRIPT_DIR}/chart"
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

function create_certmanager(){
  registry="quay.io"
  tag="v1.8.0"
  image_controller="jetstack/cert-manager-controller"
  image_webhook="jetstack/cert-manager-webhook"
  image_cainjectory="jetstack/cert-manager-cainjector"

  # TODO: check these don't exist
  (
    az acr import --name "$AZURE_ACR_NAME" --source "$registry/$image_controller:$tag" --image "$image_controller:$tag" && \
    az acr import --name "$AZURE_ACR_NAME" --source "$registry/$image_webhook:$tag" --image "$image_webhook:$tag" && \
    az acr import --name "$AZURE_ACR_NAME" --source "$registry/$image_cainjectory:$tag" --image "$image_cainjectory:$tag"
  ) || true

  acr_url="$AZURE_ACR_NAME.azurecr.io"

  kubectl label namespace "$API_CLUSTER_NAMESPACE" cert-manager.io/disable-validation=true

  helm repo add jetstack https://charts.jetstack.io
  helm repo update

  helm upgrade \
    --install cert-manager jetstack/cert-manager \
    --namespace "$API_CLUSTER_NAMESPACE" \
    --version="$tag" \
    --set installCRDs=true \
    --set nodeSelector."kubernetes\.io/os"=linux \
    --set image.repository="$acr_url/$image_controller" \
    --set image.tag="$tag" \
    --set webhook.image.repository="$acr_url/$image_webhook" \
    --set webhook.image.tag="$tag" \
    --set cainjector.image.repository="$acr_url/$image_cainjectory" \
    --set cainjector.image.tag="$tag"

    # TODO: ping until up
    sleep 30
}

function create_nginx_ingress(){

  helm repo add ingress-nginx https://kubernetes.github.io/ingress-nginx
  helm repo update

  helm upgrade \
    --install ingress-nginx ingress-nginx/ingress-nginx \
    --namespace "$API_CLUSTER_NAMESPACE" \
    --set controller.service.annotations."service\.beta\.kubernetes\.io/azure-dns-label-name"="$domain_label" \
    --set controller.service.annotations."service\.beta\.kubernetes\.io/azure-load-balancer-health-probe-request-path"=/healthz
}

domain_label=$(python -c "import sys; print(sys.argv[1].split('.')[0])" "$AZURE_DOMAIN")

assert_azure_logged_in
write_tf_vars
terraform_apply "${SCRIPT_DIR}/terraform"
(write_kube_config)
create_namespace_if_required "$API_CLUSTER_NAMESPACE"
create_nginx_ingress
create_certmanager
write_chart_values
install_chart
build_api_image
push_api_image

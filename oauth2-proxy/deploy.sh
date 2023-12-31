#!/bin/bash

SCRIPT_DIR=$( cd -- "$( dirname -- "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )
. "${SCRIPT_DIR}/../init.sh"


function install_chart(){
  helm repo add oauth2-proxy https://oauth2-proxy.github.io/manifests

  client_id="$("$SCRIPT_DIR/aad_app_registration/output.sh" client_id)"
  client_secret="$("$SCRIPT_DIR/aad_app_registration/output.sh" client_secret)"
  cookie_secret="$(openssl rand -base64 32 | head -c 32 | base64)"
  config_file="$SCRIPT_DIR/oauth2-proxy.cfg"

  cat "$SCRIPT_DIR/oauth2-proxy.base.cfg" > "$config_file"
  echo 'redirect_url = "'"$API_REDIRECT_URL"'"' >> "$config_file"
  echo 'oidc_issuer_url = "'"https://login.microsoftonline.com/${AZURE_TENANT_ID}"'/v2.0"' >> "$config_file"

  helm upgrade \
    --debug \
    --install oauth2-proxy oauth2-proxy/oauth2-proxy \
    --namespace "$API_CLUSTER_NAMESPACE" \
    --set config.clientID="$client_id" \
    --set config.clientSecret="$client_secret" \
    --set config.cookieSecret="$cookie_secret" \
    --set config.configFile="$(cat "$config_file")"
}

"${SCRIPT_DIR}/aad_app_registration/deploy.sh"
install_chart

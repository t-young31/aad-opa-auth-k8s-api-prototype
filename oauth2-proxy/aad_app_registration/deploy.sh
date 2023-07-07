#!/bin/bash
#set -x trace

SCRIPT_DIR=$( cd -- "$( dirname -- "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )
# shellcheck source=/dev/null
. "${SCRIPT_DIR}/../../init.sh"

function ensure_logged_in(){
  cyan='\033[1;36m'; no_color='\033[0m'

  echo -e "Ensuring logged in with:"
  echo -e "${cyan}Tenant id:${no_color}       ${AZURE_TENANT_ID}"
  echo -e "${cyan}Subscription id:${no_color} ${AZURE_SUBSCRIPTION_ID}"

  ids=$(az account show --query "{tenantId:tenantId,subscriptionid:id}" -o tsv)

  if ! echo "$ids" | grep -q "$AZURE_TENANT_ID"; then
    error "Wrong tenant!"
  elif ! echo "$ids" | grep -q "$AZURE_SUBSCRIPTION_ID"; then
    error "Wrong subscription!"
  fi
}

function write_tf_vars(){
    cat <<EOF > "${SCRIPT_DIR}/terraform/terraform.tfvars"
# Auto generated – edits will be overridden
app_name = "$AZURE_APP_REGISTRATION_NAME"
redirect_url = "https://${API_DOMAIN}/oauth2/callback"
EOF
}

function terraform_apply() {
  cd "${SCRIPT_DIR}/terraform" || exit
  terraform init -upgrade
  terraform validate
  terraform apply --auto-approve
}

ensure_logged_in
write_tf_vars
terraform_apply

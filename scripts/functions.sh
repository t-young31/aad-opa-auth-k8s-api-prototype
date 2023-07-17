#!/bin/bash

function error(){
  echo "$1"
  exit 1
}

function assert_command_exists(){
    command="$1"; error_string="$2"
    if ! command -v "$command" &> /dev/null; then
        error "$error_string"
    fi
}

function assert_file_exists(){
    filepath="$1"; error_string="$2"
    if [ ! -f "$filepath" ]; then
        error "$error_string"
    fi
}

function terraform_apply(){
  directory="$1"
  (
    cd "$directory" || exit
    terraform init -upgrade
    terraform validate
    terraform apply --auto-approve
  )
}

function terraform_destroy(){
  directory="$1"
  (
    cd "$directory" || exit
    terraform apply -destroy --auto-approve
  )
}

function assert_azure_logged_in(){
  cyan='\033[1;36m'; no_color='\033[0m'

  echo -e "Ensuring logged in with:"
  echo -e "${cyan}Tenant id:${no_color}       ${AZURE_TENANT_ID}"
  echo -e "${cyan}Subscription id:${no_color} ${AZURE_SUBSCRIPTION_ID}"
  assert_command_exists az "Please install the Azure CLI with e.g.: pip install azure-cli"

  ids=$(az account show --query "{tenantId:tenantId,subscriptionid:id}" -o tsv)

  if ! echo "$ids" | grep -q "$AZURE_TENANT_ID"; then
    error "Wrong tenant!"
  elif ! echo "$ids" | grep -q "$AZURE_SUBSCRIPTION_ID"; then
    error "Wrong subscription!"
  fi
}

function create_namespace_if_required(){
  namespace="$1"
  kubectl create namespace "$namespace" \
    --dry-run=client -o yaml | kubectl apply -f -
}

#!/bin/bash
#set -x trace

SCRIPT_DIR=$( cd -- "$( dirname -- "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )
# shellcheck source=/dev/null
. "${SCRIPT_DIR}/../../init.sh"

function write_tf_vars(){
    cat <<EOF > "${SCRIPT_DIR}/terraform/terraform.tfvars"
# Auto generated – edits will be overridden
app_name = "$AZURE_APP_REGISTRATION_NAME"
redirect_url = "$API_REDIRECT_URL"
EOF
}

assert_azure_logged_in
write_tf_vars
terraform_apply "${SCRIPT_DIR}/terraform"

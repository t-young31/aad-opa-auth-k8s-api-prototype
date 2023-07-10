#!/bin/bash
#set -x trace

SCRIPT_DIR=$( cd -- "$( dirname -- "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )
# shellcheck source=/dev/null
. "${SCRIPT_DIR}/../init.sh"

function write_tf_vars(){
    cat <<EOF > "${SCRIPT_DIR}/terraform/terraform.tfvars"
# Auto generated – edits will be overridden
aws_prefix = "$AWS_PREFIX"
EOF
}

function terraform_apply() {
  cd "${SCRIPT_DIR}/terraform" || exit
  terraform init -upgrade
  terraform validate
  terraform apply --auto-approve
}

write_tf_vars
terraform_apply

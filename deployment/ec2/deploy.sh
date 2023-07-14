#!/bin/bash
#set -x trace

SCRIPT_DIR=$( cd -- "$( dirname -- "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )
# shellcheck source=/dev/null
. "${SCRIPT_DIR}/../../init.sh"

function write_tf_vars(){
    cat <<EOF > "${SCRIPT_DIR}/terraform/terraform.tfvars"
# Auto generated – edits will be overridden
aws_prefix = "$AWS_PREFIX"
EOF
}

write_tf_vars
terraform_apply "${SCRIPT_DIR}/terraform"
echo "Please ssh onto the EC2 instance and run: make deploy"

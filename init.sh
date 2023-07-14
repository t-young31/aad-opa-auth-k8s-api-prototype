#!/bin/bash
set -o errexit
set -o pipefail
set -o nounset

_SCRIPT_DIR=$( cd -- "$( dirname -- "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )
# shellcheck source=/dev/null
. "${_SCRIPT_DIR}/scripts/functions.sh"  # Export shared functions

function create_venv_if_required(){
  if [ ! -d "${_SCRIPT_DIR}/.venv" ]; then
    assert_command_exists python3 "Please install python"
    python3 -m venv .venv
    . .venv/bin/activate
    pip install -r scripts/requirements.txt
  fi
}

function assert_flags_are_valid(){

  for flag in "$DEBUG" "$PRODUCTION"; do
      if [ "$flag" != "True" ] && [ "$flag" != "False" ]; then
        error "Invalid value for flag. Please use true or false"
      fi
  done

  if [ "$DEBUG" == "True" ] && [ "$PRODUCTION" == "True" ]; then
    error "Cannot run in debug mode in production"
  fi
}

assert_command_exists k3d "Needs a k3d install. See: https://github.com/k3d-io/k3d"
assert_command_exists terraform "Needs a terraform install. See https://developer.hashicorp.com/terraform/tutorials/aws-get-started/install-cli"

config_filepath="$_SCRIPT_DIR/config.yaml"
assert_file_exists "$config_filepath" "Failed to find a config.yaml file. Please create one from config.sample.yaml"

create_venv_if_required
source .venv/bin/activate   # Activate python virtual environment

echo "Exporting env vars created from ${config_filepath}"
"${_SCRIPT_DIR}/scripts/print_key_value_pairs_from_yaml.py" "$config_filepath" > .env
read -ra args < <(xargs < .env)
export "${args[@]}"

assert_flags_are_valid

# Export additional environment variables
export KUBECONFIG="${_SCRIPT_DIR}/${CLUSTER_CONFIG_FILE}"

if [ -z "${AZURE_ACR_NAME+x}" ]; then  # is unset
  export API_IMAGE_FULL="${API_IMAGE_NAME}:${API_IMAGE_TAG}"
else
  export API_IMAGE_FULL="${AZURE_ACR_NAME}.azurecr.io/api/${API_IMAGE_NAME}:${API_IMAGE_TAG}"
fi

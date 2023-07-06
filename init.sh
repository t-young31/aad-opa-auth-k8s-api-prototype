#!/bin/bash
set -o errexit
set -o pipefail
set -o nounset

SCRIPT_DIR=$( cd -- "$( dirname -- "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )

function assert_command_exists(){
    command="$1"; error_string="$2"
    if ! command -v "$command" &> /dev/null; then
        echo "$error_string"
        exit 1
    fi
}

function assert_file_exists(){
    filepath="$1"; error_string="$2"
    if [ ! -f "$filepath" ]; then
        echo "$error_string"
        exit 1
    fi
}

function create_venv_if_required(){
  if [ ! -d "${SCRIPT_DIR}/.venv" ]; then
    assert_command_exists python "Please install python"
    python -m venv .venv
    . .venv/bin/activate
    pip install -r scripts/requirements.txt
  fi
}


assert_command_exists k3d "Needs a k3d install. See: https://github.com/k3d-io/k3d"

config_filepath="$SCRIPT_DIR/config.yaml"
assert_file_exists "$config_filepath" "Failed to find a config.yaml file. Please create one from config.sample.yaml"

create_venv_if_required
source .venv/bin/activate   # Activate python virtual environment

echo "Exporting env vars created from ${config_filepath}"
"${SCRIPT_DIR}/scripts/print_key_value_pairs_from_yaml.py" "$config_filepath" > .env
read -ra args < <(xargs < .env)
export "${args[@]}"

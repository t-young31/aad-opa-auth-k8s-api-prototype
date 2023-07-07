#!/bin/bash

output_name="$1"
SCRIPT_DIR=$( cd -- "$( dirname -- "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )

(
  cd "$SCRIPT_DIR/terraform" || exit
  terraform output -raw "$output_name"
)

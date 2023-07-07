#!/bin/bash

SCRIPT_DIR=$( cd -- "$( dirname -- "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )
# shellcheck source=/dev/null
. "${SCRIPT_DIR}/../../init.sh"

KEY_FILEPATH="${SCRIPT_DIR}/${NGINX_SSL_CERT_FILENAME}"
CERT_FILEPATH="${SCRIPT_DIR}/${NGINX_SSL_KEY_FILENAME}"

if [ -f "$KEY_FILEPATH" ] && [ -f "$CERT_FILEPATH" ]; then
  echo "Found key and cert. Not creating"
  exit 0
fi

set +u  # Allow unset variables

# Create a self-signed certificate with a 10 year expiry and no passphrase
openssl req -x509 \
  -newkey rsa:4096 \
  -keyout "$KEY_FILEPATH" \
  -out "$CERT_FILEPATH" \
  -sha256 \
  -days 3650 \
  -nodes \
  -subj "/C=GB/CN=localhost"

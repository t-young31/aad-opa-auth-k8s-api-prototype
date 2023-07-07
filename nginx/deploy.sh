#!/bin/bash
# set -x trace

SCRIPT_DIR=$( cd -- "$( dirname -- "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )
# shellcheck source=/dev/null
. "${SCRIPT_DIR}/../init.sh"

"${SCRIPT_DIR}/ssl/create_if_required.sh"
# TODO: inject values from file


(
  # See: https://docs.nginx.com/nginx-ingress-controller/installation/installation-with-manifests/
  cd "${SCRIPT_DIR}/kubernetes-ingress/deployments" || exit
  kubectl apply -f common/ns-and-sa.yaml  # Create namespace & service account
  kubectl apply -f rbac/rbac.yaml  # Add cluster role for the service account
  kubectl apply -f common/ingress-class.yaml  # Create ingress class

  kubectl apply -f "${SCRIPT_DIR}/server-secret.yaml"  # Add tls certs
  kubectl apply -f "${SCRIPT_DIR}/nginx-conf.yaml"  # Create config map

  # Run custom resource definitions
  kubectl apply -f common/crds/k8s.nginx.org_virtualservers.yaml
  kubectl apply -f common/crds/k8s.nginx.org_virtualserverroutes.yaml
  kubectl apply -f common/crds/k8s.nginx.org_transportservers.yaml
  kubectl apply -f common/crds/k8s.nginx.org_policies.yaml

  # Apply the deployment
  kubectl apply -f daemon-set/nginx-ingress.yaml
)

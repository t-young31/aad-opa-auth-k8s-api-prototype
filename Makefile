.PHONY: *
SHELL:=/bin/bash


all:
	echo "Please choose a target e.g. local"; exit 1

local:
	echo "🚀 Deploying local k8s infrastructure"
	./deployment/local/deploy.sh
	$(MAKE) api

destroy-local: destroy-aad-app-reg
	echo "🔥 Destroying local k8s infrastructure"
	./deployment/local/destroy.sh

api: oauth2-proxy opa
	echo "🚀 Deploying API"
	./api/deploy.sh

oauth2-proxy:
	echo "🚀 Deploying oauth2-proxy"
	./oauth2-proxy/deploy.sh

aad-app-reg:
	echo "🚀 Deploying Azure active directory app registration"
	./oauth2-proxy/aad_app_registration/deploy.sh

destroy-aad-app-reg:
	echo "🔥 Destroying Azure active directory app registration"
	./oauth2-proxy/aad_app_registration/destroy.sh

opa:
	echo "🚀 Deploying OPA"
	./opa/deploy.sh

ec2:
	echo "🚀 Deploying AWS ec2 instance"
	./deployment/ec2/deploy.sh

destroy-ec2:
	echo "🔥 Destroying AWS ec2 instance"
	./deployment/ec2/destroy.sh

aks:
	echo "🚀 Deploying Azure Kubernetes Service (AKS)"
	./deployment/aks/deploy.sh
	$(MAKE) api

destroy-aks:
	echo "🔥 Destroying AKS"
	./deployment/aks/destroy.sh


.SILENT: # silence all targets

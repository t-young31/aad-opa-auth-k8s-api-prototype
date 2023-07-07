.PHONY: deploy destroy deploy-api deploy-core
SHELL:=/bin/bash


deploy: deploy-api

destroy:
	echo "Destroying 🔥"
	./destroy.sh

deploy-core:
	echo "Deploying core infrastructure 🚀"
	./deploy.sh

deploy-api: deploy-core deploy-oauth2-proxy
	echo "Deploying API 🚀"
	./api/deploy.sh

deploy-oauth2-proxy:
	echo "Deploying oauth2-proxy 🚀"
	./oauth2-proxy/deploy.sh


.SILENT: # silence all targets

.PHONY: deploy destroy deploy-api deploy-core deploy-oauth2-proxy deploy-aad-app-reg destroy-aad-app-reg
SHELL:=/bin/bash


deploy: deploy-api

destroy: destroy-aad-app-reg
	echo "🔥 Destroying core infrastructure"
	./destroy.sh

deploy-core:
	echo "🚀 Deploying core infrastructure"
	./deploy.sh

deploy-api: deploy-core deploy-oauth2-proxy
	echo "🚀 Deploying API"
	./api/deploy.sh

deploy-oauth2-proxy:
	echo "🚀 Deploying oauth2-proxy"
	./oauth2-proxy/deploy.sh

deploy-aad-app-reg:
	echo "🚀 Deploying Azure active directory app registration "
	./oauth2-proxy/aad_app_registration/deploy.sh

destroy-aad-app-reg:
	echo "🔥 Destroying Azure active directory app registration"
	./oauth2-proxy/aad_app_registration/destroy.sh


.SILENT: # silence all targets

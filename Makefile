SHELL:=/bin/bash


deploy: deploy-api

destroy:
	echo "Destroying 🔥"
	./destroy.sh

deploy-core:
	echo "Deploying core infrastructure 🚀"
	./deploy.sh

deploy-api: deploy-core
	echo "Deploying API 🚀"
	./api/deploy.sh


.SILENT: # silence all targets

SHELL:=/bin/bash
.SILENT: deploy destroy

deploy:
	echo "Deploying 🚀"
	./deploy.sh

destroy:
	echo "Destroying 🔥"
	./destroy.sh

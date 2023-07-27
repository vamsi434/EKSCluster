setup:
	terraform init -backend-config state/backend.config
	terraform validate

validate:
	terraform validate

plans:
	terraform plan -var-file="env/inputs.tfvars"

refresh:
	terraform plan -var-file="env/inputs.tfvars" -refresh-only

apply:
	terraform apply -var-file="env/inputs.tfvars"

output:
	@cd scripts && bash output.bash

target-apply:
	@read -p "Enter the module name:" module;\
	terraform apply -var-file="env/inputs.tfvars" --target=module.$$module
	# terraform apply -var-file="env/inputs.tfvars" --target=module.${module}

destroy-target:
	@read -p "Enter the module name:" module;\
	terraform apply -var-file="env/inputs.tfvars" --target=module.$$module
	# terraform destroy -var-file="env/inputs.tfvars" --target=module.${module}
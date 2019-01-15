# Usage:
# 	make (env) (task)
#
sandbox:
	$(eval export TF_VAR_env=sandbox)
	$(eval export env_dir=sandbox)
	$(eval export TF_VAR_is_production=false)
	@true

dev:
	$(eval export TF_VAR_env=dev)
	$(eval export env_dir=dev)
	$(eval export TF_VAR_is_production=false)
	@true

init:
	$(if $(and ${TF_VAR_env}, ${env_dir}),,$(error Usage: make <env> <action> OR TF_VAR_env=<env> make <env> <action>))
	terraform init -reconfigure

plan: init
	terraform plan -var-file=${env_dir}/terraform.tfvars

apply: init
	terraform apply -var-file=${env_dir}/terraform.tfvars

destroy: init
	terraform destroy -var-file=${env_dir}/terraform.tfvars | grep -v 'Still destroying...'

.PHONY : init plan apply destroy sandbox dev

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

build-lambda:
	cd scripts/update-reporting-db
	rm -rf ./vendor/bundle
	# need to build native extensions within a docker container that's as close
	# as possible to the ultimate lambda runtime
	docker run --rm -v "$PWD":/var/task lambci/lambda:build-ruby2.5 \
		yum install postgresql postgresql-devel && \
		cd scripts/update-reporting-db && \
		gem install bundler && \
		bundle install --deployment

run-lambda:
	cd scripts/update-reporting-db
	sam local invoke --no-event --env-vars=./.env.json

.PHONY : init plan apply destroy sandbox dev build-lambda _install _test

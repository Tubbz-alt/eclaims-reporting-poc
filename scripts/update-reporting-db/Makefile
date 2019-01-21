# lots of this opied from https://github.com/stevenringo/lambda-ruby-pg-nokogiri/blob/master/Makefile
# With huge thanks to https://github.com/stevenringo
ndef = $(if $(value $(1)),,$(error $(1) not set))

image:
	docker build -t lambda-ruby2.5-postgresql10 -f lambda.dockerfile .

shell:
	docker run --rm -it -v $$PWD:/var/task -w /var/task lambda-ruby2.5-postgresql10

install:
	docker run --rm -it -v $$PWD:/var/task -w /var/task lambda-ruby2.5-postgresql10 make _install

test:
	docker run --rm -it -v $$PWD:/var/task -w /var/task lambda-ruby2.5-postgresql10 make _test

run:
	docker run --rm -it -v $$PWD:/var/task -w /var/task lambda-ruby2.5-postgresql10 make _run

zip:
	rm -f deploy.zip
	zip -q -r deploy.zip . -x .git/\*

clean:
	rm -rf .bundle/
	rm -rf vendor/
	rm -rf lib/
	rm ./pg_ext.so

invoke_local:
	sam local invoke --no-event --env-vars ./.env.json

setup_env:
	$(eval export AWS_REGION=eu-west-1)
	$(eval export FUNCTION_NAME=UpdateReportingDBFunction)
	$(eval export ROLE_ARN=arn:aws:iam::090682378586:role/MHCLG-Lambda-Role)

deploy: setup_env
	aws lambda create-function \
			--region ${AWS_REGION} \
			--function-name ${FUNCTION_NAME} \
			--zip-file fileb://deploy.zip \
			--runtime ruby2.5 \
			--role ${ROLE_ARN} \
			--timeout 60 \
			--handler run_lambda.main

update: setup_env
	aws lambda update-function-code \
			--region ${AWS_REGION} \
			--function-name ${FUNCTION_NAME} \
			--zip-file fileb://deploy.zip

# given an ENV_VAR_STRING in the form:
# Variables={KeyName1=string,KeyName2=string}
# or the JSON equivalent,
# apply those env vars to the latest version of
# the Lambda function
# TODO: replace all of these API calls with Terraform resources,
# so that the parameters can be calculated by TF
update_env_vars_and_config: setup_env
	$(call ndef,ENV_VAR_STRING)  			# $$ENV_VAR_STRING is required
	$(call ndef,SUBNET_IDS)  					# $$SUBNET_IDS is required
	$(call ndef,SECURITY_GROUP_IDS)  	# $$SECURITY_GROUP_IDS is required
	aws lambda update-function-configuration \
		--region ${AWS_REGION} \
		--function-name ${FUNCTION_NAME} \
		--environment '${ENV_VAR_STRING}' \
		--vpc-config SubnetIds=${SUBNET_IDS},SecurityGroupIds=${SECURITY_GROUP_IDS}

delete: setup_env
	aws lambda delete-function \
			--region ${AWS_REGION} \
			--function-name ${FUNCTION_NAME}

invoke: setup_env
	$(call ndef,OUTFILE)  # $$OUTFILE is required
	aws lambda invoke \
		--region ${AWS_REGION} \
		--function-name ${FUNCTION_NAME} \
		${OUTFILE}

# Commands that start with underscore are run *inside* the container.
_install:
	bundle config --local build.pg --with-pg-config=/usr/pgsql-10/bin/pg_config
	bundle config --local silence_root_warning true
	bundle install --path vendor/bundle --clean
	mkdir -p /var/task/lib
	cp -a /usr/pgsql-10/lib/*.so.* /var/task/lib/

_test:
	ruby -e "require 'lambda_handler'; puts debug_native_gems(event: nil, context: nil)"

_run:
	ruby -e "require 'lambda_handler'; puts main(event: nil, context: nil)"

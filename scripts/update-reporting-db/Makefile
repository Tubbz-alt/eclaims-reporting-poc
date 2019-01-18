# Copied from https://github.com/stevenringo/lambda-ruby-pg-nokogiri/blob/master/Makefile
# With huge thanks to https://github.com/stevenringo

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

setup_env:
	$(eval export FUNCTION_NAME=UpdateReportingDBFunction)
	$(eval export ROLE_ARN=arn:aws:iam::090682378586:role/MHCLG-Lambda-Role)

deploy: setup_env
	aws lambda create-function \
			--region ${AWS_REGION} \
			--function-name ${FUNCTION_NAME} \
			--zip-file fileb://deploy.zip \
			--runtime ruby2.5 \
			--role ${ROLE_ARN} \
			--timeout 20 \
			--handler lambda_handler.main

update: setup_env
	aws lambda update-function-code \
			--region ap-southeast-2 \
			--function-name ${FUNCTION_NAME} \
			--zip-file fileb://deploy.zip

delete: setup_env
	aws lambda delete-function \
			--region ap-southeast-2 \
			--function-name ${FUNCTION_NAME}

invoke:
	aws lambda invoke \
		--region ap-southeast-2 \


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

## To setup:

### for local development

Prequisites:
* ruby (tested on v.2.5.3, should work on all 2.x)
* rubygems (tested on v2.7.6)
* a Postgres database (tested on 10.3, should be backwards compatible to ... 9?)

```
# From the scripts/update-reporting-db directory:
gem install bundler
bundle install

# to setup the database schema:
bundle exec rake db:setup
```


## To run:

You will need the following environment variables:

* S3_BUCKET_NAME
  Name of the bucket from which to download files.

* S3_BUCKET_REGION
  S3 has subtly different addressing schemes for US vs EU buckets.
  It will fail to access the bucket if this region is not set correctly.

* AWS_ACCESS_KEY & AWS_SECRET_ACCESS_KEY
  Credentials for the AWS account used to download the CSV files.

* DATABASE_URL
  Of the form: postgres://username:password@host:port/database_name?pool=size

We highly recommend setting these in a .env file.

### for local development

```
# From the scripts/update-reporting-db directory:
bundle exec ruby run.rb
```

The app uses the dotenv gem to automatically load environment variables from
a file in the root directory of the application called .env, if it exists.
You can also pass env vars on the command line like so:

```
S3_BUCKET_NAME=my-bucket S3_BUCKET_REGION=us-east-1 bundle exec ruby run.rb
```


### locally via docker

To build the docker image:

```
# From the scripts/update-reporting-db directory:
docker build -t (some convenient tag - e.g. 'mhclg-reporting-poc') .
```

To run the image as a container:
```
docker run --env-file (env file path) (image tag)
```
or if you prefer to set individual env vars explicitly:
```
docker run -e S3_BUCKET_NAME=my-bucket -e S3_BUCKET_REGION=us-east-1 (image tag)
```

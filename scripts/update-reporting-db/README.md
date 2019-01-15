# update-reporting-db

A ruby script that will download claims & claim-lines extracts from a given S3
bucket, connect to a postgresql database on a given URL, and replace any
existing claim & claim-line records with those in the extract files.

Some notes on the extract files:

* The S3 object paths are defined in [model/config.rb](https://github.com/communitiesuk/eclaims-reporting-poc/blob/master/scripts/update-reporting-db/model/config.rb#L4)
* Although the files have a .csv extension, the column delimiter is expected to be a pipe (|) - this is how the application supplier's code generates them.
* In some lines in the sample files, we observed invalid timestamps - fields would have several timestamps concatenated together, e.g. "2018-07-05T14:21:35.838738Z2018-06-14T14:10:28.887455Z2018-04-19T14:04:21.875331Z". ActiveRecord will automatically parse the first recognisable timestamp (in this case '2018-07-05T14:21:35.838738Z') and discard the rest.
* The headers in the extract files separate words in field names with dashes - e.g. 'claim-doc-id'. For compatibility with ActiveRecord and the underlying Postgresql DB, any dashes in fields names are mapped to underscores (e.g. 'claim_doc_id')

## To setup for local development

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

* *S3_BUCKET_NAME*
Name of the bucket from which to download files.

* *S3_BUCKET_REGION*
S3 has subtly different addressing schemes for US vs EU buckets.
It will fail to access the bucket if this region is not set correctly.

* *AWS_ACCESS_KEY* and *AWS_SECRET_ACCESS_KEY*
Credentials for the AWS account used to download the CSV files.

* *DATABASE_URL*
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

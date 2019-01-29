require 'model/app'
require 'model/simple_event'
require 'model/s3_downloader'

class S3Event < SimpleEvent
  attr_accessor :raw_json, :parsed_json, :bucket_name, :name, :region, :key

  def initialize(params = {})
    @bucket_name  = params[:bucket_name]
    @key          = params[:key]
    @name         = params[:name]
    @parsed_json  = params[:parsed_json]
    @raw_json     = params[:raw_json]
    @region       = params[:region]
  end

  def run!
    if name == 'ObjectCreated:Put'
      # new object in an S3 bucket
      # so let's download and import it
      app = App.new(
        s3_downloader: S3Downloader.new(
          region: region,
          bucket_name: bucket_name
        )
      )
      app.download_and_import_file!(filename: key)
    else
      raise ArgumentError.new("I don't know how to handle that event: '#{event}'")
    end
  end

  def self.from_parsed_json!(event)
    record = event['Records'].first
    new(
      bucket_name: record['s3']['bucket']['name'],
      key: record['s3']['object']['key'],
      name: record['eventName'],
      parsed_json: event,
      region: event['awsRegion']
    )
  end
end

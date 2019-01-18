class S3Downloader
  attr_accessor :region, :bucket_name, :client

  def initialize( args={} )
    self.region = args.fetch(:region, nil)
    self.bucket_name = args.fetch(:bucket_name, nil)
    self.client = region ? Aws::S3::Client.new(region: region) : Aws::S3::Client.new
  end

  def download( target_path:, object_key: )
    puts "AWS_ACCESS_KEY: #{ENV['AWS_ACCESS_KEY']}, AWS_SECRET_ACCESS_KEY: #{ENV['AWS_SECRET_ACCESS_KEY']}"
    client.get_object(
      bucket: self.bucket_name,
      key: object_key,
      response_target: target_path
    )
  end
end

class S3Downloader
  attr_accessor :region, :bucket_name, :client

  def initialize( args={} )
    self.region = args.fetch(:region)
    self.bucket_name = args.fetch(:bucket_name)
    self.client = Aws::S3::Client.new(region: region)
  end

  def download( target_path:, object_key: )
    client.get_object(
      bucket: self.bucket_name,
      key: object_key,
      response_target: target_path
    )
  end
end

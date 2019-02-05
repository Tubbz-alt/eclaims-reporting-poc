class Config
  attr_accessor :s3, :file_model_map

  DEFAULT_FILE_MODEL_MAP = {
    'csv/claims.csv' => 'claim',
    'csv/claim-lines.csv' => 'claim_line'
  }

  def initialize( args = {} )
    self.s3 = args[:s3] || {}
    self.file_model_map = args[:file_model_map] || DEFAULT_FILE_MODEL_MAP
  end

  def self.from_env_vars
    new(
      s3: s3_env_vars
    )
  end

  def self.s3_env_vars
    {
      bucket_name: ENV['S3_BUCKET_NAME'],
      bucket_region: ENV['S3_BUCKET_REGION']
    }
  end
end

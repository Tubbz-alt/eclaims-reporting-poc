class Config
  attr_accessor :db, :s3, :file_table_map

  DEFAULT_FILE_TABLE_MAP = {
    'csv/claims.csv' => 'claims',
    'csv/claim-lines.csv' => 'claim_lines'
  }

  def initialize( args = {} )
    self.db = args[:db] || {}
    self.s3 = args[:s3] || {}
    self.file_table_map = args[:file_table_map] || DEFAULT_FILE_TABLE_MAP
  end

  def self.from_env_vars
    new(
      db: db_env_vars,
      s3: s3_env_vars
    )
  end

  def self.db_env_vars
    {
      dbname: ENV['DB_NAME'],
      host: ENV['DB_HOST'],
      password: ENV['DB_PASSWORD'],
      port: ENV['DB_PORT'],
      user: ENV['DB_USERNAME']
    }
  end

  def self.s3_env_vars
    {
      bucket_name: ENV['S3_BUCKET_NAME'],
      bucket_region: ENV['S3_BUCKET_REGION']
    }
  end
end

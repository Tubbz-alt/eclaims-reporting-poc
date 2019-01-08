#!/usr/bin/ruby

require_relative './app_setup'

require 'fileutils'
require 'tmpdir'

require 'model/config'
require 'model/postgres_db'
require 'model/shell_adapter'

def log(line)
  puts line
end

def download( target_path:, bucket_name:, object_key:, region: )
  s3 = Aws::S3::Client.new(region: region)
  resp = s3.get_object(
    response_target: target_path,
    bucket: bucket_name,
    key: object_key
  )
end

def main
  config = Config.from_env_vars
  db = PostgresDB.new(config.db)

  config.file_table_map.each do |filename, table_name|
    file_path = File.join(Dir.tmpdir, filename)
    FileUtils.mkdir_p(File.dirname(file_path))
    log "downloading #{filename}"
    resp = download( bucket_name: config.s3.fetch(:bucket_name),
      region: config.s3.fetch(:bucket_region),
      object_key: filename,
      target_path: file_path
    )
    puts ShellAdapter.output_of( 'wc', '-l', file_path )

    log "importing to table #{table_name}"
    db.drop_if_exists(table_name)
    db.exec_file(File.join(APP_ROOT, 'sql', table_name + '.sql'))
    db.import_csv(file_path: file_path, table_name: table_name, delimiter: '|')
  end
end


main

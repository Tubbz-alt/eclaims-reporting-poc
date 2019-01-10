require 'csv'
require 'fileutils'
require 'tmpdir'

require 'model/config'
require 'model/csv_importer'
require 'model/shell_adapter'
require 'model/s3_downloader'

class App
  attr_accessor :logger, :config, :csv_importer, :s3_downloader

  def initialize(args={})
    self.logger = args[:logger] || default_logger
    self.config = args[:config] || default_config
    self.csv_importer = args[:csv_importer] || default_csv_importer
    self.s3_downloader = args[:s3_downloader] || default_s3_downloader
  end

  def download(s3_path)
    file_path = File.join(Dir.tmpdir, s3_path)
    FileUtils.mkdir_p(File.dirname(file_path))
    logger.info "downloading #{s3_path}"
    s3_downloader.download( object_key: s3_path, target_path: file_path )
    file_path
  end

  def report_lines_in(file_path)
    logger.info [
      file_path,
      '-',
      ShellAdapter.output_of( 'wc', '-l', file_path ),
      'lines'
    ].join(' ')
  end

  def import_csv(file_path:, model_name:)
    logger.info "Importing file #{file_path} to model #{model_name}"
    csv_importer.import_csv(file_path: file_path, model_name: model_name)
  end

  def run!
    config.file_model_map.each do |filename, model_name|
      file_path = download(filename)
      report_lines_in(file_path)
      import_csv(file_path: file_path, model_name: model_name)
    end
  end

  def default_logger
    Logger.new(STDOUT)
  end

  def default_s3_downloader
    S3Downloader.new(
      bucket_name: config.s3.fetch(:bucket_name),
      region: config.s3.fetch(:bucket_region)
    )
  end

  def default_csv_importer
    CSVImporter.new(logger: logger)
  end

  def default_config
    Config.from_env_vars
  end
end

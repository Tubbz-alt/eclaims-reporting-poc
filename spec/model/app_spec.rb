require_relative '../spec_helper'

require 'model/app'

RSpec::Matchers.define :a_string_matching do |regex|
  match { |actual| actual =~ regex }
end

describe App do
  let(:mock_s3_config) { {bucket_region: 'nowhere', bucket_name: 'mybucket'} }
  let(:mock_s3_downloader) { instance_double(S3Downloader) }
  let(:mock_logger) { instance_double(Logger) }
  let(:mock_config) { instance_double(Config, s3: mock_s3_config)}
  let(:mock_csv_importer) { instance_double(CSVImporter) }

  describe '.initialize' do
    subject { App.new(args) }

    context 'given no args' do
      let(:args) { {} }

      it 'creates a new App' do
        expect(subject).to be_a(App)
      end

      describe 'the logger' do
        before do
          allow_any_instance_of(described_class).to receive(:default_logger).and_return(mock_logger)
        end
        it 'is the default_logger' do
          expect(subject.logger).to eq(mock_logger)
        end
      end

      describe 'the config' do
        before do
          allow_any_instance_of(described_class).to receive(:default_config).and_return(mock_config)
        end
        it 'is the default_config' do
          expect(subject.config).to eq(mock_config)
        end
      end

      describe 'the csv_importer' do
        before do
          allow_any_instance_of(described_class).to receive(:default_csv_importer).and_return(mock_csv_importer)
        end
        it 'is the default_csv_importer' do
          expect(subject.csv_importer).to eq(mock_csv_importer)
        end
      end

      describe 'the s3_downloader' do
        before do
          allow_any_instance_of(described_class).to receive(:default_s3_downloader).and_return(mock_s3_downloader)
        end
        it 'is the default_s3_downloader' do
          expect(subject.s3_downloader).to eq(mock_s3_downloader)
        end
      end
    end

    context 'given a :logger' do
      let(:args) { {logger: 'mock logger'} }

      it 'stores the given logger' do
        expect(subject.logger).to eq('mock logger')
      end
    end

    context 'given a :config' do
      let(:args) { {config: mock_config} }

      it 'stores the given config' do
        expect(subject.config).to eq(mock_config)
      end
    end

    context 'given a :csv_importer' do
      let(:args) { {csv_importer: mock_csv_importer} }

      it 'stores the given csv_importer' do
        expect(subject.csv_importer).to eq(mock_csv_importer)
      end
    end
  end

  describe '#default_logger' do
    before do
      allow(Logger).to receive(:new).with(STDOUT).and_return(mock_logger)
    end
    it 'creates a Logger for STDOUT' do
      expect(Logger).to receive(:new).with(STDOUT).and_return(mock_logger)
      subject.default_logger
    end
    it 'is the created STDOUT Logger' do
      expect(subject.default_logger).to eq(mock_logger)
    end
  end

  describe '#default_config' do
    before do
      allow(Config).to receive(:from_env_vars).and_return(mock_config)
    end
    it 'creates a Config from env vars' do
      expect(Config).to receive(:from_env_vars).and_return(mock_config)
      subject.default_config
    end
    it 'is the created Config' do
      expect(subject.default_config).to eq(mock_config)
    end
  end

  describe '#default_csv_importer' do
    before do
      subject.logger = mock_logger
      allow(CSVImporter).to receive(:new).with(logger: mock_logger).and_return(mock_csv_importer)
    end

    it 'creates a CSVImporter passing on its logger' do
      expect(CSVImporter).to receive(:new).with(logger: mock_logger).and_return(mock_csv_importer)
      subject.default_csv_importer
    end

    it 'is the created CSVImporter' do
      expect(subject.default_csv_importer).to eq(mock_csv_importer)
    end
  end

  describe '#default_s3_downloader' do
    before do
      subject.config.s3 = mock_s3_config
      allow(S3Downloader).to receive(:new).with(
        bucket_name: mock_s3_config[:bucket_name],
        region: mock_s3_config[:bucket_region]
      ).and_return(mock_s3_downloader)

    end

    it 'creates an S3Downloader passing on the configs bucket_name and bucket_region as region' do
      expect(S3Downloader).to receive(:new).with(
        bucket_name: mock_s3_config[:bucket_name],
        region: mock_s3_config[:bucket_region]
      ).and_return(mock_s3_downloader)
      subject.default_s3_downloader
    end

    it 'is the created S3Downloader' do
      expect(subject.default_s3_downloader).to eq(mock_s3_downloader)
    end
  end

  describe '#download' do
    before do
      allow(Dir).to receive(:tmpdir).and_return('/my/tmp/dir')
      allow(FileUtils).to receive(:mkdir_p)
      allow(subject.s3_downloader).to receive(:download)
    end

    it 'makes a temp dir ending in the s3 path' do
      expect(FileUtils).to receive(:mkdir_p).with('/my/tmp/dir/my/s3')
      subject.download('my/s3/object.txt')
    end

    it 'asks the s3_downloader to download the given s3_path to the temp dir' do
      expect(subject.s3_downloader).to receive(:download).with(
        object_key: 'my/s3/object.txt',
        target_path: '/my/tmp/dir/my/s3/object.txt'
      )
      subject.download('my/s3/object.txt')
    end

    it 'returns the temp file location' do
      expect(subject.download('my/s3/object.txt')).to eq('/my/tmp/dir/my/s3/object.txt')
    end
  end

  describe '#report_lines_in' do
    before do
      allow(ShellAdapter).to receive(:output_of).with('wc', '-l', 'my/file/path').and_return(42)
    end

    it 'counts the lines in the file' do
      expect(ShellAdapter).to receive(:output_of).with('wc', '-l', 'my/file/path').and_return(42)
      subject.report_lines_in('my/file/path')
    end

    it 'logs the number of lines' do
      expect(subject.logger).to receive(:info).with(a_string_matching(/my\/file\/path - 42 lines/))
      subject.report_lines_in('my/file/path')
    end
  end

  describe '#import_csv' do
    before do
      allow(subject.csv_importer).to receive(:import_csv).with(file_path: 'my/file/path', model_name: 'MyModel')
    end

    it 'logs what it is about to do' do
      expect(subject.logger).to receive(:info).with("Importing file my/file/path to model MyModel")
      subject.import_csv(file_path: 'my/file/path', model_name: 'MyModel')
    end

    it 'asks the csv_importer to import the given file_path and model_name' do
      expect(subject.csv_importer).to receive(:import_csv).with(file_path: 'my/file/path', model_name: 'MyModel')
      subject.import_csv(file_path: 'my/file/path', model_name: 'MyModel')
    end
  end

  describe 'run!' do
    describe 'for each filename and model_name in config.file_model_map' do
      before do
        allow(subject.config).to receive(:file_model_map).and_return({'my/file/path' => 'MyModel'})
        allow(subject).to receive(:download).with('my/file/path').and_return('/a/local/file')
        allow(subject).to receive(:report_lines_in)
        allow(subject).to receive(:import_csv)
      end

      it 'downloads the filename' do
        expect(subject).to receive(:download).with('my/file/path')
        subject.run!
      end

      it 'calls report_lines_in the downloaded file' do
        expect(subject).to receive(:report_lines_in).with('/a/local/file')
        subject.run!
      end

      it 'calls import_csv passing the downloaded file as file_path and the model name as model_name' do
        expect(subject).to receive(:import_csv).with(file_path: '/a/local/file', model_name: 'MyModel')
        subject.run!
      end
    end
  end
end

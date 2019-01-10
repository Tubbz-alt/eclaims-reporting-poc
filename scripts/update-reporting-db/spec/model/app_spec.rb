require_relative '../spec_helper'

require 'model/app'
require 'byebug'

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

  describe 'default_logger' do
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

  describe 'default_config' do
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

  describe 'default_csv_importer' do
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

  describe 'default_s3_downloader' do
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
end

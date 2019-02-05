require_relative '../spec_helper'

require 'model/config'

describe Config do
  describe '.initialize' do
    let(:args) { {} }
    subject { described_class.new(args) }

    context 'given :s3' do
      let(:args) { { s3: 's3 param' } }

      it 'stores the given :s3' do
        expect(subject.s3).to eq('s3 param')
      end
    end
    context 'given no :s3 param' do
      it 'stores an empty hash as s3' do
        expect(subject.s3).to eq({})
      end
    end

    context 'given :file_model_map' do
      let(:args) { { file_model_map: 'file_model_map param' } }

      it 'stores the given :file_model_map' do
        expect(subject.file_model_map).to eq('file_model_map param')
      end
    end
    context 'given no :file_model_map param' do
      it 'stores DEFAULT_FILE_MODEL_MAP as file_model_map' do
        expect(subject.file_model_map).to eq(described_class::DEFAULT_FILE_MODEL_MAP)
      end
    end
  end

  describe '.from_env_vars' do
    it 'returns a new instance' do
      expect(described_class.from_env_vars).to be_a(described_class)
    end

    describe 'the returned instance' do
      subject { described_class.from_env_vars }
      before do
        allow(described_class).to receive(:s3_env_vars).and_return('s3_env_vars result')
      end

      it 'has s3 set to the result of s3_env_vars' do
        expect(subject.s3).to eq('s3_env_vars result')
      end
    end
  end

  describe '.s3_env_vars' do
    before do
      allow(ENV).to receive(:[]).with('S3_BUCKET_NAME').and_return('s3 bucket name from env var')
      allow(ENV).to receive(:[]).with('S3_BUCKET_REGION').and_return('s3 bucket region from env var')
    end
    it 'returns a hash' do
      expect(described_class.s3_env_vars).to be_a(Hash)
    end

    describe 'the returned hash' do
      let(:hash) { described_class.s3_env_vars }

      it 'has :bucket_name set to ENV["S3_BUCKET_NAME"]' do
        expect(hash.fetch(:bucket_name)).to eq('s3 bucket name from env var')
      end

      it 'has :bucket_region set to ENV["S3_BUCKET_REGION"]' do
        expect(hash.fetch(:bucket_region)).to eq('s3 bucket region from env var')
      end
    end
  end
end

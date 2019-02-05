  require_relative '../spec_helper'

require 'model/s3_downloader'

describe S3Downloader do
  describe '.initialize' do
    let(:args) { {} }
    subject { described_class.new(args) }

    context 'given a :region' do
      let(:args) { {region: 'some-region'} }

      it 'stores the given :region' do
        expect(subject.region).to eq('some-region')
      end
    end

    context 'given no :region' do
      it 'has nil region' do
        expect(subject.region).to be_nil
      end
    end

    context 'given a :bucket_name' do
      let(:args) { {bucket_name: 'some-bucket-name'} }

      it 'stores the given :bucket_name' do
        expect(subject.bucket_name).to eq('some-bucket-name')
      end
    end

    context 'given no :bucket_name' do
      it 'has nil bucket_name' do
        expect(subject.bucket_name).to be_nil
      end
    end

    describe ':client' do
      let(:client) { subject.client }
      let(:args) { {region: 'eu-west-2'} }

      it 'is an Aws::S3::Client' do
        expect(client).to be_a(Aws::S3::Client)
      end
      it 'has the given region_name as region' do
        expect(client.config.region).to eq('eu-west-2')
      end
    end
  end

  describe 'download' do
    before do
      subject.bucket_name = 'my-bucket'
    end
    it 'calls get_object on the client, passing its own bucket_name as :bucket the given target_path as :response_target, and the given object_key as :key' do
      expect(subject.client).to receive(:get_object).with(
        bucket: 'my-bucket',
        response_target: '/my/target/path',
        key: '/my/object.key'
      )
      subject.download(
        target_path: '/my/target/path',
        object_key: '/my/object.key'
      )
    end
  end
end

require_relative '../spec_helper'

require 'model/csv_importer'

describe CSVImporter do
  let(:mock_model) { double('model') }

  describe '#initialize' do
    let(:mock_logger) { instance_double(Logger) }
    subject { described_class.new(args) }

    context 'given a :logger' do
      let(:args) { {logger: mock_logger} }

      it 'stores the given logger' do
        expect(subject.logger).to eq(mock_logger)
      end
    end

    context 'given no :logger' do
      let(:args) { {} }
      it 'creates a Logger' do
        expect(subject.logger).to be_a(Logger)
      end
    end
  end

  describe '#set_attributes' do
    let(:object) { double('object', attribute_1: true) }

    context 'given a hash of attribute names to values as line:' do
      let(:line) { {'attribute_1' => 'value 1'} }

      it 'sets all the given attribute names on the object to the given values' do
        expect(object).to receive(:attribute_1=).with('value 1')
        subject.set_attributes(object: object, line: line)
      end

      context 'where the attribute names have dashes in them' do
        let(:line) { {'attribute-1' => 'value 1'} }

        it 'sets all the given attribute names with dashes replaced with _ on the object to the given values' do
          expect(object).to receive(:attribute_1=).with('value 1')
          subject.set_attributes(object: object, line: line)
        end
      end
    end
  end

  describe '#import_line' do
    let(:mock_line) { double('Line', to_h: {}) }
    let(:mock_instance) { double('mock instance') }
    let(:mock_class) { double('class') }
    let(:mock_record) { double('record') }
    before do
      allow(mock_class).to receive(:new).and_return(mock_instance)
      allow(mock_record).to receive(:save!)
      allow(subject).to receive(:set_attributes).with(object: mock_instance, line: mock_line).and_return(mock_record)
    end

    it 'calls set_attributes with a new instance of the model as :object, and the given :line' do
      expect(subject).to receive(:set_attributes).with(object: mock_instance, line: mock_line).and_return(mock_record)
      subject.import_line(model: mock_class, line: mock_line)
    end

    it 'save!s the returned record' do
      expect(mock_record).to receive(:save!)
      subject.import_line(model: mock_class, line: mock_line)
    end

    it 'returns the record' do
      expect(subject.import_line(model: mock_class, line: mock_line)).to eq(mock_record)
    end
  end

  describe '#model_from_name' do
    before do
      allow(subject).to receive(:require).with('model/string')
    end
    it 'requires the given name from the model/ dir' do
      expect(subject).to receive(:require).with('model/string')
      subject.model_from_name('string')
    end

    it 'returns the corresponding class' do
      expect(subject.model_from_name('string')).to eq(String)
    end
  end

  describe '#delete_all' do
    let(:mock_class) { double('class', delete_all: true, name: 'mock_class') }

    it 'calls delete_all on the given model' do
      expect(mock_class).to receive(:delete_all)
      subject.delete_all(mock_class)
    end
  end

  describe '#import_csv' do
    before do
      allow(subject).to receive(:model_from_name).and_return(mock_model)
      allow(subject).to receive(:delete_all)
      allow(subject).to receive(:import_lines)
    end

    it 'calls model_from_name with the given model:' do
      expect(subject).to receive(:model_from_name).with('model name').and_return(mock_model)
      subject.import_csv(model_name: 'model name', file_path: '/my/file/path')
    end

    it 'calls delete_all passing the result of model_from_name' do
      expect(subject).to receive(:delete_all).with(mock_model)
      subject.import_csv(model_name: 'model name', file_path: '/my/file/path')
    end

    it 'calls import_lines passing the result of model_from_name, and the given file_path' do
      expect(subject).to receive(:import_lines).with(mock_model, '/my/file/path')
      subject.import_csv(model_name: 'model name', file_path: '/my/file/path')
    end
  end

  describe '#import_lines' do
    context 'when the given file_path has no lines' do
      before do
        allow(CSV).to receive(:foreach)
      end

      it 'returns 0' do
        expect(subject.import_lines(mock_model, '/my/file/path')).to eq(0)
      end
    end

    context 'when the given file_path has at least one line' do
      before do
        allow(CSV).to receive(:foreach).and_yield('line')
      end

      it 'calls import_line once for each line, passing the line and given model' do
        expect(subject).to receive(:import_line).with(model: mock_model, line: 'line')
        subject.import_lines(mock_model, '/my/file/path')
      end
    end
  end
end

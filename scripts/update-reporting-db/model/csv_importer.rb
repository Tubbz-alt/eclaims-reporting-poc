require 'csv'

class CSVImporter
  attr_accessor :logger

  def initialize(logger: Logger.new(STDOUT))
    self.logger = logger
  end

  def create_model(model:, line:)
    record = model.new
    line.to_h.each do |key, value|
      # ActiveRecord can't handle dashes in attribute names
      # so we replace them all with underscores
      record.send(key.gsub('-', '_') + '=', value)
    end
    record
  end

  def import_line(line:, model:)
    record = create_model(model: model, line: line)
    record.save!
    record
  end

  def model_from_name(model_name)
    require "model/#{model_name}"
    model = model_name.classify.constantize
  end

  def import_csv(file_path:, model_name:)
    model = model_from_name(model_name)
    logger.info "Deleting all #{model_name.pluralize}"
    model.delete_all

    # there is a header, so data starts from line 1
    line_number = 1
    CSV.foreach(file_path, headers: true, col_sep: '|') do |line|
      logger.debug "importing #{model} from line #{line_number}: #{line.first(2)}"
      import_line(line: line, model: model)
      line_number = line_number + 1
    end
  end
end

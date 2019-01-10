require 'csv'

class CSVImporter
  attr_accessor :logger

  def initialize(logger: Logger.new(STDOUT))
    self.logger = logger
  end

  def set_attributes(object:, line:)
    line.to_h.each do |key, value|
      # ActiveRecord can't handle dashes in attribute names
      # so we replace them all with underscores
      object.send(key.gsub('-', '_') + '=', value)
    end
    object
  end

  def import_line(line:, model:)
    record = set_attributes(object: model.new, line: line)
    record.save!
    record
  end

  def model_from_name(model_name)
    require "model/#{model_name}"
    model = model_name.classify.constantize
  end

  def delete_all(model)
    logger.info "Deleting all #{model.name.pluralize}"
    model.delete_all
  end

  def import_lines(model, file_path)
    # there is a header, so data starts from line 1
    # but when the file has no lines in it, we want to return 0
    # so we initialize the counter to 0, and put an increment
    # in the loop _before_ importing
    line_number = 0
    CSV.foreach(file_path, headers: true, col_sep: '|') do |line|
      line_number = line_number + 1
      logger.debug "importing #{model} from line #{line_number}: #{line.first(2)}"
      import_line(line: line, model: model)
    end
    line_number
  end

  def import_csv(file_path:, model_name:)
    model = model_from_name(model_name)
    delete_all(model)
    import_lines(model, file_path)
  end
end

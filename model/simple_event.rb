class SimpleEvent
  attr_accessor :raw_json, :parsed_json, :name

  def initialize(params={})
    @name         = params[:name]
    @raw_json     = params[:raw_json]
    @parsed_json  = params[:parsed_json]
  end

  def run!
    case name
    when "run_migrations"
      # need to run migrations
      run_migrations!
    else
      raise ArgumentError.new("I couldn't handle that event: '#{name}'")
    end
  end

  def run_migrations!
    puts "Running migrations"
    # lambda executes on a read-only filesystem except for /tmp/
    # so we need to copy the schema.rb file to /tmp/ and load it from there
    unless ENV['SCHEMA'].to_s.empty?
      puts "copying db/schema.rb to #{ENV['SCHEMA']}"
      ShellAdapter.exec('cp', 'db/schema.rb', ENV['SCHEMA'])
    end
    puts %x[rake db:setup db:migrate]
  end

  def self.from_json!(json)
    instance = begin
      from_parsed_json!(JSON.parse(json))
    rescue NoMethodError => e
      raise ArgumentError.new("I couldn't parse that event: '#{e}'")
    end
    instance.raw_json = json
    instance
  end

  def self.from_parsed_json!(event)
    new(
      name: event['name'],
      parsed_json: event
    )
  end
end

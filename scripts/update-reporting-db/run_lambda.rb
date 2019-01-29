#!/usr/bin/ruby

require_relative './app_setup'

require 'model/app'
require 'model/s3_downloader'
require 'model/s3_event'

def main(event:, context:)
  puts "event: '#{event}'"
  puts "context: '#{context.inspect}'"

  if event.to_s.empty?
    App.new.run!
  elsif event.is_a?(Hash)
    if event['Records']
      s3_event = parse_s3_event!(event)
      s3_event.run!
    else
      event = SimpleEvent.from_parsed_json!(event)
      event.run!
    end
  end
end

def parse_s3_event!(event)
  if event.is_a?(Hash)
    S3Event.from_parsed_json!(event)
  elsif event.is_a?(String)
    S3Event.from_json!(event)
  else
    raise ArgumentError.new("I couldn't handle that event '#{event}'")
  end
end

def dump_params(event:, context:)
  response = { event: JSON.generate(event), context: JSON.generate(context.inspect) }
  puts response.to_s
end

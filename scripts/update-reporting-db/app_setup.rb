require 'rubygems'
# for some as-yet-unknown reason, this require fails when running
# locally via SAM. TODO: figure out why
unless ENV['SKIP_BUNDLER_SETUP']
  require 'bundler/setup'
end
require 'aws-sdk-s3'

unless ENV['SKIP_DOTENV']
  dotenv_file = ENV['DOTENV_FILE'] || '.env'
  puts "loading dotenv from #{dotenv_file}"
  require 'dotenv'
  Dotenv.load(dotenv_file)
end

require 'active_record'
ActiveRecord::Base.establish_connection(ENV['DATABASE_URL'])

APP_ROOT = File.dirname(__FILE__)

$LOAD_PATH.unshift(APP_ROOT)

require 'rubygems'
# for some as-yet-unknown reason, this require fails when running
# locally via SAM. TODO: figure out why
unless ENV['SKIP_BUNDLER_SETUP']
  require 'bundler/setup'
end
require 'aws-sdk-s3'

puts "ENV['SKIP_DOTENV']=#{ENV['SKIP_DOTENV']}"
unless ENV['SKIP_DOTENV']
  puts "loading dotenv"
  require 'dotenv'
  Dotenv.load
end

require 'active_record'
puts "ENV['DATABASE_URL']=#{ENV['DATABASE_URL']}"
ActiveRecord::Base.establish_connection(ENV['DATABASE_URL'])

APP_ROOT = File.dirname(__FILE__)

$LOAD_PATH.unshift(APP_ROOT)

require 'rubygems'
# require 'bundler/setup'
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

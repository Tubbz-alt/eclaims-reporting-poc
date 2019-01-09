require 'rubygems'
require 'bundler/setup'
require 'aws-sdk-s3'

require 'dotenv'
Dotenv.load

require 'active_record'
ActiveRecord::Base.establish_connection(ENV['DATABASE_URL'])

APP_ROOT = File.dirname(__FILE__)

$LOAD_PATH.unshift(APP_ROOT)

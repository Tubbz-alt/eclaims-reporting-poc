require 'rubygems'
require 'bundler/setup'
require 'aws-sdk-s3'

require 'dotenv'
Dotenv.load

APP_ROOT = File.dirname(__FILE__)

$LOAD_PATH.unshift(APP_ROOT)

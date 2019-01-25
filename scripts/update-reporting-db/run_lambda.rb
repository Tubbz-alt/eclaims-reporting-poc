#!/usr/bin/ruby

require_relative './app_setup'

require 'model/app'

def main(event:, context:)
  # need to run migrations
  %x[rake db:setup db:migrate]
  App.new.run!
end

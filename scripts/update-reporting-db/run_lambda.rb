#!/usr/bin/ruby

require_relative './app_setup'

require 'model/app'

def main(event:, context:)
  App.new.run!
end

#!/usr/bin/ruby

require_relative './app_setup'

require 'model/app'

def main
  App.new.run!
end

main

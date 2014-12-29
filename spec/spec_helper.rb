require "codeclimate-test-reporter"
CodeClimate::TestReporter.start

require 'rubygems'
require 'bundler/setup'
require 'vcr_setup'
require 'api_key'
require 'bea_api'

def api_key
  RSPEC_API_KEY
end

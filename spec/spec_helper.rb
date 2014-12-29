require 'rubygems'
require 'bundler/setup'
require 'vcr_setup'
require 'api_key'
require 'bea_api'

def api_key
  RSPEC_API_KEY
end

# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'bea_api/version'

Gem::Specification.new do |spec|
  spec.name          = "bea_api"
  spec.version       = BeaApi::VERSION
  spec.authors       = ["Chad Hoersten"]
  spec.summary       = %q{Ruby wrapper for the US Bureau of Economic Analysis (BEA) API}
  spec.description   = %q{Ruby wrapper for the US Bureau of Economic Analysis (BEA) API at http://www.bea.gov/api/.  This API is used to pull United States economic data by geography.}
  spec.homepage      = "https://github.com/hoersten/bea_api"
  spec.license       = "MIT"

  spec.files         = `git ls-files -z`.split("\x0")
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ["lib"]

  spec.add_runtime_dependency 'rest-client'
  spec.add_development_dependency "bundler", "~> 1.7"
  spec.add_development_dependency "rake", "~> 10.0"
  spec.add_development_dependency 'rspec'
  spec.add_development_dependency 'rspec-rails'
  spec.add_development_dependency 'vcr'
  spec.add_development_dependency 'webmock'
  spec.add_development_dependency 'codeclimate-test-reporter'
end

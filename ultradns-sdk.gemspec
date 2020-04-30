# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'ultradns/version'

Gem::Specification.new do |spec|
  spec.name          = "ultradns-sdk"
  spec.version       = Ultradns::VERSION
  spec.authors       = ["ultradns"]
  spec.email         = ["ultrasupport@neustar.biz"]
  spec.summary       = %q{UltraDNS SDK for manipulating zones managed by UltraDNS}
  spec.description   = %q{Manipulate zones or add, update, remove records in UltraDNS}
  spec.homepage      = ""
  spec.license       = "Apache 2.0"


  spec.files         = `git ls-files -z`.split("\x0")
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ["lib"]

  spec.add_dependency "httparty", "~> 0.18"

  spec.add_development_dependency "bundler", "~> 1.6"
  spec.add_development_dependency "rake"
  spec.add_development_dependency "mocha", "~> 1.1.0"
  spec.add_development_dependency "minitest", "~> 5.4.0"
  spec.add_development_dependency "simplecov", "~> 0.9.0"
  spec.add_development_dependency "vcr", "~> 2.9.2"
  spec.add_development_dependency "fakeweb", '>= 1.3.0'

end

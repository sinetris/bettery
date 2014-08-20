# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'bettery/version'

Gem::Specification.new do |spec|
  spec.name          = "bettery"
  spec.version       = Bettery::VERSION
  spec.authors       = ["Duilio Ruggiero"]
  spec.email         = ["duilio.ruggiero@gmail.com"]
  spec.summary       = %q{Betterplace API wrapper in Ruby.}
  spec.description   = %q{Ruby toolkit for working with the Betterplace API.}
  spec.homepage      = "https://github.com/sinetris/bettery"
  spec.license       = "MIT"

  spec.files         = `git ls-files -z`.split("\x0")
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ["lib"]

  spec.required_ruby_version = "~> 2.0"

  spec.add_development_dependency "bundler", "~> 1.6"

  spec.add_runtime_dependency 'sawyer', '~> 0.5'
end

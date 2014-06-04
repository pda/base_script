# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'base_script/version'

Gem::Specification.new do |spec|
  spec.name          = "base_script"
  spec.version       = BaseScript::VERSION
  spec.authors       = ["Paul Annesley"]
  spec.email         = ["paul@annesley.cc"]
  spec.summary       = %q{CLI script simple base class.}
  spec.description   = %q{Small base for CLI scripts; signal handling, indented logging, colors ticks/crosses, injectable args/IO.}
  spec.homepage      = "https://github.com/pda/base_script"
  spec.license       = "MIT"

  spec.files         = `git ls-files -z`.split("\x0")
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ["lib"]

  spec.add_development_dependency "bundler", "~> 1.5"
  spec.add_development_dependency "rake"
end

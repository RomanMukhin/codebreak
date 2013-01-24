# -*- encoding: utf-8 -*-
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'codebreak/version'

Gem::Specification.new do |gem|
  gem.name          = "codebreak"
  gem.version       = Codebreak::VERSION
  gem.authors       = ["Roman Mukhin"]
  gem.email         = ["roman11mukhin@gmail.com"]
  gem.description   = %q{The first version of codebreaker}
  gem.summary       = %q{Codebreaker game for TDD first attempts}
  gem.homepage      = ""

  gem.files         = Dir['lib/**/*.rb'] + Dir['bin/*'] + Dir['*'] + Dir['spec/**/*.rb']
  gem.executables   = ['codebreak']
  gem.test_files    = gem.files.grep(%r{^(test|spec|features)/})
  gem.require_paths = ["lib"]

  gem.add_development_dependency('rspec')
end

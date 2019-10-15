# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'pg_lock/version'

Gem::Specification.new do |spec|
  spec.name          = "pg_lock"
  spec.version       = PgLock::VERSION
  spec.authors       = ["mikehale", "schneems"]
  spec.email         = ["mike@hales.ws", "richard.schneeman@gmail.com"]

  spec.summary       = %q{ Use Postgres advisory lock to isolate code execution across machines }
  spec.description   = %q{ A Postgres advisory lock client }
  spec.homepage      = "http://github.com/heroku/pg_lock"
  spec.license       = "MIT"

  spec.files         = `git ls-files -z`.split("\x0").reject { |f| f.match(%r{^(test|spec|features)/}) }
  spec.bindir        = "exe"
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]

  spec.add_development_dependency "pg", ">= 0.15"
  spec.add_development_dependency "activerecord", ">= 2.3"
  spec.add_development_dependency "bundler", "~> 2"
  spec.add_development_dependency "rake", "~> 10.0"

  spec.add_development_dependency "rspec", "~> 3.1"
end


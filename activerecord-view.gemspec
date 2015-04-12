# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'activerecord/view/version'

Gem::Specification.new do |spec|
  spec.name          = "activerecord-view"
  spec.version       = ActiveRecord::View::VERSION
  spec.authors       = ["Alexa Grey"]
  spec.email         = ["devel@mouse.vc"]

  spec.summary       = %q{SQL views with ActiveRecord}
  spec.description   = %q{SQL views with ActiveRecord}
  spec.homepage      = "https://github.com/scryptmouse/activerecord-view"

  spec.files         = `git ls-files -z`.split("\x0").reject { |f| f.match(%r{^(test|spec|features)/}) }
  spec.bindir        = "exe"
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]
  spec.required_ruby_version = '~> 2.1'

  spec.add_dependency "activerecord", "> 4.1", "< 5"
  spec.add_dependency "dux"
  spec.add_dependency "virtus", "~> 1.0"

  spec.add_development_dependency "bundler", "~> 1.9"
  spec.add_development_dependency "rake", "~> 10.0"
  spec.add_development_dependency "combustion"
  spec.add_development_dependency "database_cleaner"
  spec.add_development_dependency "rspec"
  spec.add_development_dependency "pry"
  spec.add_development_dependency "mysql2"
  spec.add_development_dependency "sqlite3"
  spec.add_development_dependency "pg"
  spec.add_development_dependency "simplecov"
end

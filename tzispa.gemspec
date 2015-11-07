# -*- encoding: utf-8 -*-
require File.expand_path('../lib/tzispa/version', __FILE__)

Gem::Specification.new do |s|
  s.name        = Tzispa::FRAMEWORK_NAME.downcase
  s.version     = Tzispa::VERSION
  s.platform    = Gem::Platform::RUBY
  s.authors     = ['Juan Antonio Piñero']
  s.email       = ['japinero@area-integral.com']
  s.homepage    = 'https://www.area-integral.com'
  s.summary     = 'A sparkling web framework'
  s.description = 'A sparkling web framework based on Rack and inspired by Sinatra and Lotus'
  s.licenses    = ['MIT']

  s.required_rubygems_version = '~> 2.0'
  s.required_ruby_version     = '~> 2.0'

  s.add_dependency 'rack',           '~> 1.5'
  s.add_dependency 'http_router',    '~> 0.11'
  s.add_dependency 'sequel',         '~> 4.24'
  s.add_dependency 'moneta',         '~> 0.8'
  s.add_dependency 'tzispa_helpers', '~> 0.1.0'
  s.add_dependency 'tzispa_utils',   '~> 0.1.2'
  s.add_dependency 'tzispa_rig',     '~> 0.2.0'

  s.files         = Dir.glob("{lib}/**/*") + %w(README.md CHANGELOG.md)
  s.require_paths = ['lib']
end

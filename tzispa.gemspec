# frozen_string_literal: true

require File.expand_path('../lib/tzispa/version', __FILE__)

Gem::Specification.new do |s|
  s.name        = Tzispa::FRAMEWORK_NAME.downcase
  s.version     = Tzispa::VERSION
  s.platform    = Gem::Platform::RUBY
  s.bindir      = 'bin'
  s.authors     = ['Juan Antonio Piñero']
  s.email       = ['japinero@area-integral.com']
  s.homepage    = 'https://github.com/japiber/tzispa'
  s.summary     = 'A sparkling web framework'
  s.description = 'A sparkling web framework Rack based'
  s.licenses    = ['MIT']

  s.required_ruby_version = '~> 2.4'

  s.add_dependency 'dotenv',         '~> 2.2'
  s.add_dependency 'http_router',    '~> 0.11.2'
  s.add_dependency 'i18n',           '~> 0.9.0'
  s.add_dependency 'rack',           '~> 2.0', '>= 2.0.1'
  s.add_dependency 'thor',           '~> 0.20.0'
  s.add_dependency 'tzispa_config',  '~> 0.1.0'
  s.add_dependency 'tzispa_data',    '~> 0.6.0'
  s.add_dependency 'tzispa_helpers', '~> 0.3.6'
  s.add_dependency 'tzispa_rig',     '~> 0.5.10'
  s.add_dependency 'tzispa_utils',   '~> 0.3.6'

  s.add_development_dependency 'shotgun', '~> 0.9'

  s.files         = Dir.glob('{lib,bin}/**/*') + %w[README.md CHANGELOG.md LICENSE tzispa.gemspec]
  s.executables   = s.files.grep(%r{^bin/}) { |f| File.basename(f) }
  s.require_paths = ['lib']
end

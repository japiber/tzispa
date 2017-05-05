# frozen_string_literal: true

module Tzispa
  module Commands
    module Helpers
      module Project

        PROJECT_STRUCTURE = [
          'apps', 'config', 'config/locales', 'config/routes', 'data', 'logs', 'public',
          'public/css', 'public/vendors', 'public/css/fonts', 'public/css/less', 'public/img',
          'public/js', 'repository', 'scripts', 'tmp'
        ].freeze

        GEMFILE = 'Gemfile'

        PUMA_CONFIG_FILE = 'puma.rb'

        BOOT_CONFIG_FILE = 'boot.rb'

        BOOT_FILE = 'boot.rb'

        DEFAULT_MOUNT_PATH = '/'

        GIT_IGNORE = [
          '*.gem', '*.rbc', '.bundle', '.config', 'Gemfile.lock', 'test/tmp',
          'tmp', '*.bundle', ' .DS_Store', '.tzisparc', '.rubocop.yml', '.rubocop_todo.yml',
          'logs/', 'data/', 'tmp/', 'config/*.yml', 'puma.pid', 'puma.state', '.directory',
          '*.lock', '.env.*'
        ].freeze

        PUMA_CONFIG = <<-PUMACONFIG
  #!/usr/bin/env puma
  env = Tzispa::Environment.instance
  app_dir = env.root.to_s
  tmp_dir = "\#{app_dir}/tmp"
  logs_dir = "\#{app_dir}/logs"
  environment env.environment
  daemonize env.daemonize?
  pidfile "\#{tmp_dir}/puma.pid"
  state_path "\#{tmp_dir}/puma.state"
  if env.daemonize?
    stdout_redirect "\#{logs_dir}/puma.stdout", "\#{logs_dir}/puma.stderr"
  end
  workers 0
  # threads 0, 16
  if env.ssl?
    path_to_key = "\#{app_dir}/\#{env['TZISPA_SSL_KEY']}"
    path_to_cert = "\#{app_dir}/\#{env['TZISPA_SSL_CERT']}"
    bind "ssl://\#{env.server_host}:\#{env.server_port}?key=\#{path_to_key}&cert=\#{path_to_cert}"
  else
    bind "tcp://\#{env.server_host}:\#{env.server_port}"
  end
  tag '%s'
  worker_timeout 90

        PUMACONFIG

        ENVC_DEFAULTS = <<-ENVCDEFAULTS
  # Define ENV variables
  WEB_SESSIONS_SECRET="%s"
  WEB_SESSIONS_TIMEOUT=2400
  TZISPA_HOST=localhost
  TZISPA_SERVER_HOST=0.0.0.0
  # TZISPA_PORT = 9412
  # TZISPA_SERVER_PORT = 9412
  TZISPA_SSL=no
  # TZISPA_SSL_KEY=.ssl.key
  # TZISPA_SSL_CERT=.ssl.cer

        ENVCDEFAULTS

        BOOT_CONFIG = <<-BOOTCONFIG
  # frozen_string_literal: true

  require 'bundler'

  Bundler.require(*Tzispa::Environment.instance.bundler_groups)

        BOOTCONFIG

        GEMFILE_CONTENT = <<-GEMFILECONTENT
  # frozen_string_literal: true

  source 'https://rubygems.org'

  gem 'dalli'
  gem 'i18n'
  gem 'puma'
  gem 'redis'
  gem 'sequel'
  gem 'tzispa'

  group :development do
    # Code reloading
    # See: http://hanamirb.org/guides/projects/code-reloading
    gem 'shotgun'
  end

        GEMFILECONTENT

      end
    end
  end
end

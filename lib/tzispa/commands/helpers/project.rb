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

        PUMA_CONFIG_FILE = 'puma.rb'

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
app_dir = Tzispa::Environment.instance.root.to_s
tmp_dir = "\#{app_dir}/tmp"
logs_dir = "\#{app_dir}/logs"
environment Tzispa::Environment['TZISPA_ENV']
#daemonize true
pidfile "\#{tmp_dir}/puma.pid"
state_path "\#{tmp_dir}/puma.state"
# stdout_redirect 'logs/puma.stdout', 'logs/puma.stderr'
workers 0
# threads 0, 16
if Tzispa::Environment.ssl?
  path_to_key = Tzispa::Environment['TZISPA_SSL_KEY']
  path_to_cert = Tzispa::Environment['TZISPA_SSL_CERT']
  bind "ssl://\#{Tzispa::Environment.instance.server_host}:\#{Tzispa::Environment.instance.server_port}?key=\#{path_to_key}&cert=\#{path_to_cert}"
else
  bind "tcp://\#{Tzispa::Environment.instance.server_host}:\#{Tzispa::Environment.instance.server_port}"
end
tag 'your_app_tag'
worker_timeout 90
        PUMACONFIG

        ENVC_DEFAULTS = <<-ENVCDEFAULTS
# Define ENV variables
WEB_SESSIONS_SECRET="%s"
WEB_SESSIONS_TIMEOUT=2400
TZISPA_HOST=localhost
TZISPA_SSL=no
        ENVCDEFAULTS

      end
    end
  end
end

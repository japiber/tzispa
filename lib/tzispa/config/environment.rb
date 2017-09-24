# frozen_string_literal: true

module Tzispa
  module Config
    module Environment

      RACK_ENV = 'RACK_ENV'

      TZISPA_ENV = 'TZISPA_ENV'

      DEVELOPMENT_ENV = 'development'

      DEFAULT_ENV = 'development'

      PRODUCTION_ENV = 'deployment'

      RACK_ENV_DEPLOYMENT = 'deployment'

      DEFAULT_DOTENV_ENV = '.env.%s'

      DEFAULT_CONFIG = 'config'

      TZISPA_HOST = 'TZISPA_HOST'

      TZISPA_SSL = 'TZISPA_SSL'

      TZISPA_SERVER_HOST = 'TZISPA_SERVER_HOST'

      DEFAULT_HOST = 'localhost'

      TZISPA_PORT = 'TZISPA_PORT'

      TZISPA_SERVER_PORT = 'TZISPA_SERVER_PORT'

      DEFAULT_PORT = 9412

      DEFAULT_RACKUP = 'tzispa.ru'

      DEFAULT_ENVIRONMENT_CONFIG = 'environment'

      DEFAULT_DOMAINS_PATH = 'apps'

      DOMAINS = 'domains'

      DOMAINS_PATH = 'apps/%s'

      APPLICATION = 'application'

      APPLICATION_PATH = 'app'

    end
  end
end

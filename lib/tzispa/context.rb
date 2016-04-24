require 'forwardable'
require 'i18n'

module Tzispa

  # This class defines a environment to hold application state in runtime
  class Context
    extend Forwardable

    attr_reader    :env, :repository
    def_delegators :app, :config, :logger, :domain

    def initialize(environment)
      @env = environment
      @repository = app.repository.dup if app.repository
      I18n.locale = config.locales.default.to_sym if config.respond_to?(:locales)
    end

    def app
      @app ||= env[Tzispa::ENV_TZISPA_APP]
    end

  end

end

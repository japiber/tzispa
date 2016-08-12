require 'forwardable'
require 'i18n'

module Tzispa

  # This class defines a environment to hold application state in runtime
  class Context
    extend Forwardable

    attr_reader    :app, :env
    def_delegators :app, :config, :logger, :domain, :repository

    def initialize(app, environment)
      @env = environment
      @app = app
      I18n.locale = config.locales.default.to_sym if config.respond_to?(:locales)
    end

  end

end

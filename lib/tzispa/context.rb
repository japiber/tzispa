# frozen_string_literal: true

require 'forwardable'
require 'i18n'

module Tzispa

  # This class defines a environment to hold application state in runtime
  class Context
    extend Forwardable

    attr_reader    :app, :env, :cache
    def_delegators :app, :config, :logger, :domain, :repository

    def initialize(app, environment)
      @env = environment
      @app = app
      @cache = {}
      I18n.locale = app.config.locales.default.to_sym if app.config&.respond_to?(:locales)
    end
  end

end

# frozen_string_literal: true

require 'forwardable'
require 'logger'
require 'i18n'
require 'tzispa/domain'
require 'tzispa/config/app_config'
require 'tzispa/config/db_config'
require 'tzispa/template'
require 'tzispa_data'

module Tzispa

  class Application
    extend Forwardable

    include Tzispa::Template

    attr_reader :domain, :logger, :map_path, :engine, :routes
    def_delegators :@domain, :name, :path

    class << self
      alias __new__ :new

      def new(*args, &block)
        __new__(*args, &block).tap { |app| add app }
      end

      # rubocop:disable Style/ClassVars
      def applications
        synchronize do
          @@applications ||= Hash.new { |_, key| raise UnknownApplication(key.to_s) }
        end
      end

      def synchronize
        Mutex.new.synchronize { yield }
      end

      def [](name)
        applications[name]
      end

      def add(app)
        synchronize do
          raise DuplicateDomain.new(app.name) if applications.key?(app.name)
          applications[app.name] = app
        end
      end
    end

    def initialize(appid, engine:, on: nil, &block)
      @domain = Domain.new(appid)
      @map_path = on
      @engine = engine
      instance_eval(&block) if block
    end

    def call(env)
      routes.call env
    end

    def load!
      tap do |app|
        app.class.synchronize do
          logging
          load_locales
          repository&.load!(domain)
          domain.setup
          routes_setup
        end
      end
    end

    def [](domain)
      self.class[domain]
    end

    def default_layout?(layout)
      config.default_layout.to_sym == layout
    end

    def env
      Tzispa::Environment.instance
    end

    def routes_setup
      @routes = send :"template_#{engine}_routes", self, map_path
    end

    def config
      @config ||= Config::AppConfig.new(@domain).load!
    end

    def repository
      @repository ||= begin
        dbcfg = Config::DbConfig.new(env.environment)&.to_h
        Data::Repository.new(dbcfg) if dbcfg&.count&.positive?
      end
    end

    private

    def logging
      return unless config&.logging&.enabled
      @logger = Logger.new("logs/#{domain.name}.log", config.logging&.shift_age)
      @logger.level = Tzispa::Environment.development? ? Logger::DEBUG : Logger::INFO
    end

    def load_locales
      return unless config.respond_to?(:locales)
      I18n.enforce_available_locales = false
      I18n.load_path += Dir['config/locales/*.yml', "#{domain.path}/locales/*.yml"]
    end
  end

  class ApplicationError < StandardError; end
  class UnknownApplication < ApplicationError; end
  class DuplicateDomain < ApplicationError
    def initialize(app_name)
      super "You have tried to add an app with a duplicate domain name #{app_name}"
    end
  end

end

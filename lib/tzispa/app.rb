# frozen_string_literal: true

require 'forwardable'
require 'logger'
require 'i18n'
require 'tzispa/domain'
require 'tzispa/app_config'
require 'tzispa/engine'
require 'tzispa_data'

module Tzispa

  class Application
    extend Forwardable

    include Tzispa::Engine

    # rubocop:disable Style/ClassVars
    @@appmutex = Mutex.new

    attr_reader :domain, :logger, :map_path, :engine, :routes
    def_delegators :@domain, :name, :path

    class << self
      alias __new__ :new

      def new(*args, &block)
        __new__(*args, &block).tap { |app| add app }
      end

      def applications
        return __applications_container if @@appmutex.locked?
        synchronize do
          __applications_container
        end
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

      def synchronize
        @@appmutex.synchronize { yield }
      end

      private

      def __applications_container
        @@applications ||= Hash.new { |_, key| raise UnknownApplication(key.to_s) }
      end
    end
    # rubocop:enable Style/ClassVars

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
          logging_setup
          locales_setup
          Data::Repository.load!(domain)
          domain.setup
          routes_setup
        end
      end
    end

    def [](domain)
      self.class[domain]
    end

    def env
      Environment.instance
    end

    def config
      @config ||= AppConfig.new(@domain).load!
    end

    private

    def routes_setup
      @routes = send :"#{engine}_routes", self, map_path
    end

    def logging_setup
      return unless config&.logging&.enabled
      @logger = Logger.new("logs/#{domain.name}.log", config.logging&.shift_age)
      @logger.level = Tzispa::Environment.development? ? Logger::DEBUG : Logger::INFO
    end

    def locales_setup
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

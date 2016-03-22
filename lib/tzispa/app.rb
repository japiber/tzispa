# frozen_string_literal: true

require 'forwardable'
require 'logger'
require 'i18n'
require 'tzispa/domain'
require 'tzispa/config/appconfig'
require 'tzispa/config/routes'
require 'tzispa/middleware'
require 'tzispa_data'
require "tzispa_rig"


module Tzispa
  class Application
    extend Forwardable

    attr_reader :domain, :config, :middleware, :repository, :engine, :logger
    def_delegator :@middleware, :use
    def_delegator :@domain, :name


    class << self

      attr_accessor :routes

      def inherited(base)
        super
        base.class_eval do
          synchronize do
            applications.add(base)
          end
        end
      end

      def applications
        synchronize do
          @@applications ||= Set.new
        end
      end

      def synchronize
        Mutex.new.synchronize {
          yield
        }
      end

      def mount(mount_point, builder)
        self.new.tap { |app|
          self.routes ||= Config::Routes.new(mount_point)
          yield(routes)
          app.middleware.map mount_point, builder
        }
      end

      def router
        self.routes&.router
      end

    end

    def initialize(domain_name)
      @domain = Domain.new(domain_name)
      @middleware = Middleware.new self
      I18n.load_path = Dir["config/locales/*.yml"]
      @config = Config::AppConfig.new(@domain).load!
    end

    def call(env)
      env[:tzispa__app] = self
      middleware.call(env)
    end

    def load!
      unless @loaded
        Mutex.new.synchronize {
          @middleware.load!
          @repository = Data::Repository.new(@config.repository.to_h).load! if @config.respond_to? :repository
          @engine = Rig::Engine.new self
          @logger = Logger.new("logs/#{@domain.name}.log", 'weekly')
          @logger.level = @config.respond_to?(:developing) && @config.developing ? Logger::DEBUG : Logger::INFO
          I18n.load_path += Dir["#{@domain.path}/config/locales/*.yml"] if @config.respond_to?(:locales) && @config.locales.preload
          I18n.locale = @config.locales.default.to_sym if @config.respond_to?(:locales) && @config.locales.default
          @loaded = true
        }
      end
      self
    end

    private


  end
end

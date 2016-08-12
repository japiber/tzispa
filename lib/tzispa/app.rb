# frozen_string_literal: true

require 'forwardable'
require 'logger'
require 'i18n'
require 'tzispa/domain'
require 'tzispa/routes'
require 'tzispa/config/appconfig'
require 'tzispa/middleware'
require 'tzispa_data'
require "tzispa_rig"


module Tzispa

  ENV_TZISPA_APP     = :tzispa__app
  ENV_TZISPA_CONTEXT = :tzispa__context


  class Application
    extend Forwardable

    attr_reader :domain, :config, :middleware, :repository, :engine, :logger
    attr_accessor :routes

    def_delegator :@middleware, :use
    def_delegator :@domain, :name


    class << self
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

      def mount(path, builder)
        self.new.tap { |app|
          app.routes ||= Routes.new(app, path)
          yield(app.routes) if block_given?
          builder.map path do
            run app.middleware.builder
          end
        }
      end
    end

    def initialize(domain_name)
      @domain = Domain.new(domain_name)
      @config = Config::AppConfig.new(@domain).load!
      @middleware = Middleware.new self
    end

    def load!
      Mutex.new.synchronize {
        load_locales
        @repository = Data::Repository.new(@config.repository.to_h).load! if @config.respond_to? :repository
        @engine = Rig::Engine.new(self, @config.template_cache.enabled, @config.template_cache.size)
        @logger = Logger.new("logs/#{@domain.name}.log", 'weekly')
        @logger.level = @config.respond_to?(:developing) && @config.developing ? Logger::DEBUG : Logger::INFO
        @domain.require_dir 'helpers'
        @domain.require_dir 'api'
        @domain.require_dir 'middleware'
        @loaded = true
      }
      self
    end

    private

    def load_locales
      if @config.respond_to?(:locales)
        I18n.load_path = Dir["config/locales/*.yml"]
        I18n.load_path += Dir["#{@domain.path}/config/locales/*.yml"]
      end
    end

  end
end

# frozen_string_literal: true

require 'forwardable'
require 'logger'
require 'i18n'
require 'tzispa/domain'
require 'tzispa/routes'
require 'tzispa/config/appconfig'
require 'tzispa/middleware'
require 'tzispa/http/context'
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
          self.routes ||= Routes.new(mount_point)
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
      @config = Config::AppConfig.new(@domain).load!
    end

    def call(env)
      env[Tzispa::ENV_TZISPA_APP] = self
      env[Tzispa::ENV_TZISPA_CONTEXT] = Tzispa::Http::Context.new(env)
      middleware.call(env)
    end

    def load!
      unless @loaded
        Mutex.new.synchronize {
          load_locales
          @middleware.load!
          @repository = Data::Repository.new(@config.repository.to_h).load! if @config.respond_to? :repository
          @engine = Rig::Engine.new(self, @config.template_cache.enabled, @config.template_cache.size)
          @logger = Logger.new("logs/#{@domain.name}.log", 'weekly')
          @logger.level = @config.respond_to?(:developing) && @config.developing ? Logger::DEBUG : Logger::INFO
          @domain.require_dir 'helpers'
          @domain.require_dir 'api'
          @loaded = true
        }
      end
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

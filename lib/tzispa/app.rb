# frozen_string_literal: true

require 'forwardable'
require 'logger'
require 'i18n'
require 'tzispa/domain'
require 'tzispa/routes'
require 'tzispa/config/appconfig'
require 'tzispa/middleware'
require 'tzispa/http/context'
require 'tzispa/helpers/error_view'
require 'tzispa_data'
require "tzispa_rig"


module Tzispa

  ENV_TZISPA_APP     = :tzispa__app
  ENV_TZISPA_CONTEXT = :tzispa__context


  class Application
    extend Forwardable

    include Tzispa::Helpers::ErrorView

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
      context = Tzispa::Http::Context.new(env)
      env[Tzispa::ENV_TZISPA_CONTEXT] = context
      begin
        middleware.call(env)
      rescue StandardError, ScriptError => ex
        logger.error "#{ex.message}\n#{ex.backtrace.map { |trace| "\t #{trace}" }.join('\n') if ex.respond_to?(:backtrace) && ex.backtrace}"
        if config.developing
          context.error error_report(ex)
        else
          context.error error_page(domain)
        end
        context.response.finish
      end
    end

    def load!
      unless @loaded
        Mutex.new.synchronize {
          load_locales
          @repository = Data::Repository.new(@config.repository.to_h).load! if @config.respond_to? :repository
          @engine = Rig::Engine.new(self, @config.template_cache.enabled, @config.template_cache.size)
          @logger = Logger.new("logs/#{@domain.name}.log", 'weekly')
          @logger.level = @config.respond_to?(:developing) && @config.developing ? Logger::DEBUG : Logger::INFO
          @domain.require_dir 'helpers'
          @domain.require_dir 'api'
          @domain.require_dir 'middleware'
          @middleware.load!
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

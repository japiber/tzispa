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

    attr_reader :domain, :config, :middleware, :repository, :engine,
                :logger, :mount_path, :routes

    def_delegator :@middleware, :use
    def_delegator :@domain, :name
    def_delegators :@routes, :routing, :route_rig_index, :route_rig_api, :route_rig_signed_api, :route_rig_layout


    class << self

      def applications
        synchronize do
          @@applications ||= Hash.new{ |hash, key| raise UnknownApplication.new("#{key}") }
        end
      end

      def synchronize
        Mutex.new.synchronize {
          yield
        }
      end

      def [](name)
        applications[name]
      end

      def add(app)
        synchronize do
          raise DuplicateDomain.new("You have try to add an app with a duplicate domain name #{app.name}") if applications.has_key? app.name
          applications[app.name] = app
        end
      end

      def run(domain_name, builder: nil, on: nil, &block)
        theapp = self.new domain_name, on: on, &block
        theapp.run builder
      end

    end

    def initialize(domain_name, on: nil, &block)
      @domain = Domain.new(domain_name)
      @config = Config::AppConfig.new(@domain).load!
      @middleware = Middleware.new self
      @routes ||= Routes.new(self, on)
      self.class.add(self)
      instance_eval(&block) if block
    end

    def run(builder=nil)
      builder ||= ::Rack::Builder.new
      if routes.map_path
        this_app = self
        builder.map routes.map_path do
          run this_app.middleware.builder
        end
      else
        builder.run middleware.builder
      end
    end

    def load!
      self.class.synchronize {
        load_locales
        @repository = Data::Repository.new(config.repository.to_h).load! if config.respond_to? :repository
        @engine = Rig::Engine.new(self, config.template_cache.enabled, config.template_cache.size)
        @logger = Logger.new("logs/#{domain.name}.log", config.logging.shift_age).tap { |log|
          log.level = config.developing ? Logger::DEBUG : Logger::INFO
        } if config.logging&.enabled
        domain_requires
        @loaded = true
      }
      self
    end

    def [](domain)
      self.class[domain]
    end

    private

    def domain_requires
      domain.require_dir 'helpers'
      domain.require_dir 'services'
      domain.require_dir 'api'
      domain.require_dir 'middleware'
    end

    def load_locales
      if @config.respond_to?(:locales)
        I18n.load_path = Dir["config/locales/*.yml"]
        I18n.load_path += Dir["#{@domain.path}/locales/*.yml"]
      end
    end

    public

    class ApplicationError < StandardError; end
    class UnknownApplication < ApplicationError; end
    class DuplicateDomain < ApplicationError; end


  end
end

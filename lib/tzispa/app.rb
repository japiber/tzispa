# frozen_string_literal: true

require 'forwardable'
require 'logger'
require 'i18n'
require 'tzispa/domain'
require 'tzispa/route_set'
require 'tzispa/config/appconfig'
require 'tzispa_data'

module Tzispa

  class Application
    extend Forwardable

    attr_reader :domain, :config, :repository, :logger, :routes

    def_delegator :@domain, :name
    def_delegators :@routes, :map_path, :routing, :index, :api, :signed_api, :layout


    class << self

      alias :__new__ :new

      def new(*args, &block)
        __new__(*args, &block).tap { |app|
          add app
        }
      end

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

    end

    def initialize(appid, on: nil, &block)
      @domain = Domain.new(appid)
      @config = Config::AppConfig.new(@domain).load!
      @routes = RouteSet.new(self, on)
      @logger = Logger.new("logs/#{domain.name}.log", config.logging&.shift_age).tap { |log|
        log.level = Tzispa::Environment.development? ? Logger::DEBUG : Logger::INFO
      } if config.logging&.enabled
      @repository = Data::Repository.new(config.repository.to_h) if config.respond_to? :repository
      instance_eval(&block) if block
    end

    def call(env)
      routes.call env
    end

    def load!
      tap { |app|
        app.class.synchronize {
          load_locales
          domain_setup
          routes_setup
          repository&.load!(domain)
        }
      }
    end

    def [](domain)
      self.class[domain]
    end

    private

    def domain_setup
      domain.require_dir
      domain.require_dir 'helpers'
      domain.require_dir 'services'
      domain.require_dir 'api'
      domain.require_dir 'middleware'
    end

    def routes_setup
      path = "config/routes/#{name}.rb"
      routes.draw do
        contents = File.read(path)
        instance_eval(contents, File.basename(path), 0)
      end
    end

    def load_locales
      if config.respond_to?(:locales)
        I18n.enforce_available_locales = false
        I18n.load_path += Dir["config/locales/*.yml", "#{domain.path}/locales/*.yml"]
      end
    end

    public

    class ApplicationError < StandardError; end
    class UnknownApplication < ApplicationError; end
    class DuplicateDomain < ApplicationError; end


  end
end

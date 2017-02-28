# frozen_string_literal: true

require 'forwardable'
require 'logger'
require 'i18n'
require 'tzispa/domain'
require 'tzispa/route_set'
require 'tzispa/config/appconfig'
require 'tzispa_data'

module Tzispa

  class ApplicationError < StandardError; end
  class UnknownApplication < ApplicationError; end
  class DuplicateDomain < ApplicationError
    def initialize(app_name)
      super "You have try to add an app with a duplicate domain name #{app_name}"
    end
  end

  class Application
    extend Forwardable

    attr_reader :domain, :logger, :map_path

    def_delegators :@domain, :name, :path
    def_delegators :@routes, :routing, :index, :api, :signed_api, :layout

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
          raise DuplicateDomain(app.name) if applications.key?(app.name)
          applications[app.name] = app
        end
      end
    end

    def initialize(appid, on: nil, &block)
      @domain = Domain.new(appid)
      @map_path = on
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
          domain_setup
          routes_setup
          repository&.load!(domain)
        end
      end
    end

    def [](domain)
      self.class[domain]
    end

    def default_layout?(layout)
      config.default_layout.to_sym == layout
    end

    def environment
      @environment ||= Tzispa::Environment.instance
    end

    def routes
      @routes ||= RouteSet.new(self, map_path)
    end

    def config
      @config ||= Config::AppConfig.new(@domain).load!
    end

    def repository
      return unless config.respond_to? :repository
      @repository ||= Data::Repository.new(config.repository.to_h)
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
end

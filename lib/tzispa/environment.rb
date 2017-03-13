# frozen_string_literal: true

require 'thread'
require 'pathname'
require 'singleton'
require 'tzispa/env'
require 'tzispa/tzisparc'
require 'tzispa/utils/hash'

module Tzispa

  class Environment
    include Singleton
    using Tzispa::Utils::TzHash

    LOCK = Mutex.new

    RACK_ENV = 'RACK_ENV'

    TZISPA_ENV = 'TZISPA_ENV'

    DEVELOPMENT_ENV = 'development'

    DEFAULT_ENV = 'development'

    PRODUCTION_ENV = 'deployment'

    RACK_ENV_DEPLOYMENT = 'deployment'

    DEFAULT_DOTENV_ENV = '.env.%s'

    DEFAULT_CONFIG = 'config'

    TZISPA_HOST = 'TZISPA_HOST'

    TZISPA_SSL = 'TZISPA_SSL'

    TZISPA_SERVER_HOST = 'TZISPA_SERVER_HOST'

    DEFAULT_HOST = 'localhost'

    TZISPA_PORT = 'TZISPA_PORT'

    TZISPA_SERVER_PORT = 'TZISPA_SERVER_PORT'

    DEFAULT_PORT = 9412

    DEFAULT_RACKUP = 'tzispa.ru'

    DEFAULT_ENVIRONMENT_CONFIG = 'environment'

    DEFAULT_DOMAINS_PATH = 'apps'

    DOMAINS = 'domains'

    DOMAINS_PATH = 'apps/%s'

    APPLICATION = 'application'

    APPLICATION_PATH = 'app'

    # rubocop:disable Style/ClassVars
    @@opts = {}

    def initialize
      @env     = Tzispa::Env.new(env: @@opts.delete(:env) || ENV)
      @options = Tzispa::Tzisparc.new(root).options
      @options.merge! @@opts.clone.symbolize!
      LOCK.synchronize { set_env_vars! }
    end

    def self.opts=(hash)
      @@opts = hash.to_h.dup
    end

    def self.[](key)
      instance[key]
    end

    def self.development?
      instance.development?
    end

    def [](key)
      @env[key]
    end

    def environment
      @environment ||= env[TZISPA_ENV] || rack_env || DEFAULT_ENV
    end

    def development?
      environment == DEVELOPMENT_ENV
    end

    def code_reloading?
      development?
    end

    def environment?(*names)
      names.map(&:to_s).include?(environment)
    end

    def bundler_groups
      [:default, environment.to_sym]
    end

    def project_name
      @options.fetch(:project)
    end

    def architecture
      @options.fetch(:architecture) do
        puts "Tzispa architecture unknown: see `.tzisparc'"
        exit 1
      end
    end

    def root
      @root ||= Pathname.new(Dir.pwd)
    end

    def apps_path
      @options.fetch(:path) do
        case architecture
        when DOMAINS
          DOMAINS_PATH
        when APPLICATION
          APPLICATION_PATH
        end
      end
    end

    def config
      @config ||= root.join(@options.fetch(:config) { DEFAULT_CONFIG })
    end

    def host
      @host ||= @options.fetch(:host) do
        env[TZISPA_HOST] || DEFAULT_HOST
      end
    end

    def server_host
      @server_host ||= @options.fetch(:server_host) do
        env[TZISPA_SERVER_HOST] || host
      end
    end

    def port
      @port ||= @options.fetch(:port) do
        env[TZISPA_PORT] || DEFAULT_PORT
      end.to_i
    end

    def server_port
      @server_port ||= @options.fetch(:server_port) do
        env[TZISPA_SERVER_PORT] || port
      end.to_i
    end

    def uri_port
      if ssl?
        ":#{port}" unless port == 443
      else
        ":#{port}" unless port == 80
      end
    end

    def domains_path
      @domains_path ||= @options.fetch(:domains_path) do
        env[DOMAINS_PATH] || DEFAULT_DOMAINS_PATH
      end
    end

    def default_port?
      port == DEFAULT_PORT
    end

    def ssl?
      env[TZISPA_SSL] == 'yes'
    end

    def rackup
      root.join(@options.fetch(:rackup) { DEFAULT_RACKUP })
    end

    def daemonize?
      @options.key?(:daemonize) && @options.fetch(:daemonize)
    end

    def to_options
      @options.to_h.merge(
        environment: environment,
        apps_path:   apps_path,
        rackup:      rackup,
        host:        server_host,
        port:        server_port
      )
    end

    private

    attr_reader :env

    def set_env_vars!
      set_application_env_vars!
      set_tzispa_env_vars!
    end

    def set_tzispa_env_vars!
      env[TZISPA_ENV]  = env[RACK_ENV] = environment
      env[TZISPA_HOST] = host
      env[TZISPA_PORT] = port.to_s
    end

    def set_application_env_vars!
      dotenv = root.join(DEFAULT_DOTENV_ENV % environment)
      env.load!(dotenv) if dotenv.exist?
    end

    def rack_env
      case env[RACK_ENV]
      when RACK_ENV_DEPLOYMENT
        PRODUCTION_ENV
      else
        env[RACK_ENV]
      end
    end
  end
end

require 'thread'
require 'pathname'
require 'singleton'
require 'tzispa/env'
require 'tzispa/tzisparc'
require 'tzispa/utils/hash'

module Tzispa

  class Environment
    include Singleton
    using Tzispa::Utils

    LOCK = Mutex.new

    RACK_ENV       = 'RACK_ENV'.freeze

    TZISPA_ENV      = 'TZISPA_ENV'.freeze

    DEFAULT_ENV    = 'development'.freeze

    PRODUCTION_ENV = 'production'.freeze

    RACK_ENV_DEPLOYMENT = 'deployment'.freeze

    DEFAULT_DOTENV_ENV = '.env.%s'.freeze

    DEFAULT_CONFIG = 'config'.freeze

    TZISPA_HOST      = 'TZISPA_HOST'.freeze

    TZISPA_SSL  = 'TZISPA_SSL'.freeze

    TZISPA_SERVER_HOST = 'TZISPA_SERVER_HOST'.freeze

    DEFAULT_HOST    = 'localhost'.freeze

    TZISPA_PORT   = 'TZISPA_PORT'.freeze

    TZISPA_SERVER_PORT = 'TZISPA_SERVER_PORT'.freeze

    DEFAULT_PORT = 9412

    DEFAULT_RACKUP = 'tzispa.ru'.freeze

    DEFAULT_ENVIRONMENT_CONFIG = 'environment'.freeze

    DEFAULT_DOMAINS_PATH = 'apps'.freeze

    DOMAINS = 'domains'.freeze

    DOMAINS_PATH = 'apps/%s'.freeze

    APPLICATION = 'application'.freeze

    APPLICATION_PATH = 'app'.freeze

    @@opts = Hash.new


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

    def [](key)
      @env[key]
    end

    def environment
      @environment ||= env[TZISPA_ENV] || rack_env || DEFAULT_ENV
    end

    def environment?(*names)
      names.map(&:to_s).include?(environment)
    end

    def bundler_groups
      [:default, environment]
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
        env[TZISPA_SERVER_HOST] || env[TZISPA_HOST] || DEFAULT_HOST
      end
    end

    def port
      @port ||= @options.fetch(:port) do
        env[TZISPA_PORT] || DEFAULT_PORT
      end.to_i
    end

    def server_port
      @port ||= @options.fetch(:public_port) do
        env[TZISPA_SERVER_PORT] || env[TZISPA_PORT] || DEFAULT_PORT
      end.to_i
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
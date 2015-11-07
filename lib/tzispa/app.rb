require 'forwardable'
require 'tzispa/domain'
require 'tzispa/config/webconfig'
require 'tzispa/config/routes'
require 'tzispa/middleware'
require 'tzispa/data_adapter'
require 'tzispa/repository'
require "tzispa/rig"


module Tzispa
  class Application
    extend Forwardable

    attr_reader :domain, :router, :config, :middleware, :adapter, :repository, :engine
    def_delegator :@middleware, :use


    def self.inherited(base)
      super
      base.class_eval do
        synchronize do
          applications.add(base)
        end
      end
    end

    def self.applications
      synchronize do
        @@applications ||= Set.new
      end
    end

    def self.synchronize
      Mutex.new.synchronize {
        yield
      }
    end

    def self.mount(builder, mount_point)
      app = self.new mount_point
      builder.map mount_point do
        run app.load!
      end
    end

    def initialize(name:, map_path: nil)
      @domain = Domain.new(name: name)
      @database ||= Hash.new
      @repository ||= Hash.new
      @middleware = Tzispa::Middleware.new self
      @mutex = Mutex.new
      @map_path = map_path
    end

    def call(env)
      env[:tzispa__app] = self
      middleware.call(env)
    end

    def load!
      if !@loaded
        @mutex.synchronize {
          @config = Tzispa::Config::WebConfig.new(@domain).load!
          @router = Tzispa::Config::Routes.new(@domain).load!
          @middleware.load!
          @adapter = Tzispa::DataAdapter.new @config.data_adapter.to_h
          @repository = Tzispa::Repository.new @adapter
          @engine = Tzispa::Rig::Engine.new self
          @loaded = true
        }
      end
      self
    end

    def router_path(path_id, params={})
      "#{@map_path if @map_path != '/'}#{@router.path path_id, params}".freeze
    end

  end
end

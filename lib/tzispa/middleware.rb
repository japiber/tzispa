# frozen_string_literal: true

require 'moneta'
require 'rack/session/moneta'

module Tzispa
  class Middleware


    def initialize(app)
      @stack = []
      @application = app
    end

    def load!
      @builder = ::Rack::Builder.new
      load_default_stack
      @stack.each { |m, args, block| @builder.use load_middleware(m), *args, &block }
      @builder.run @application.class.router
      self
    end

    def map(mount_path, builder)
      app = @application
      builder.map mount_path do
        run app.load!
      end
    end

    def call(env)
      @builder.call(env)
    end

    def use(middleware, *args, &blk)
      @stack.unshift [middleware, args, blk]
    end

    private

    def load_middleware(middleware)
      case middleware
      when String
        @application.domain.const_get(middleware)
      else
        middleware
      end
    end

    def load_default_stack
      @default_stack_loaded ||= begin
        _load_session_middleware
        use Rack::MethodOverride
        true
      end
    end

    def _load_session_middleware
      if @application.config.sessions.enabled
        use Rack::Session::Moneta,
          store: Moneta.new(:HashFile, dir: @application.config.sessions.store_path, expires: true, threadsafe: true),
          key: "_#{@application.config.id}__",
          domain: @application.config.host_name,
          path: '/',
          expire_after: @application.config.sessions.timeout,
          secret: @application.config.sessions.secret
      end
    end

  end
end

# frozen_string_literal: true

require 'tzispa/http/context'

module Tzispa

  class TzispaEnv

    def initialize(main, app)
      @main = main
      @app = app
    end

    def call(env)
      env[Tzispa::ENV_TZISPA_APP] = @app
      env[Tzispa::ENV_TZISPA_CONTEXT] = Tzispa::Http::Context.new(env)
      @main.call(env)
    end
  end

  class Middleware

    attr_reader :application, :stack

    def initialize(app)
      @stack = []
      @application = app
    end

    def builder
      mw = self
      @builder ||= ::Rack::Builder.new do
        #mw.load_default_stack
        app = mw.application.load!
        mw.stack.each { |m, args, block| use mw.load(m), *args, &block }
        run app.routes.router
      end
    end

    def use(middleware, *args, &blk)
      @stack.unshift [middleware, args, blk]
    end

    def load(middleware)
      case middleware
      when String
        Object.const_get(middleware)
      else
        middleware
      end
    end

    def load_default_stack
      @default_stack_loaded ||= begin
        app = application.load!
        #use TzispaEnv, app
      end
    end


  end
end

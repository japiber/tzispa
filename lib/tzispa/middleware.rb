# frozen_string_literal: true

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
        Object.const_get(middleware)
      else
        middleware
      end
    end

    def load_default_stack
      @default_stack_loaded ||= begin
        #use Rack::MethodOverride
        true
      end
    end


  end
end

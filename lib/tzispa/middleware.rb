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
      @builder.run @application.router
      self
    end

    def load_app(path, builder)
      app = @application
      builder.map path do
        run app.load!
      end
    end

    def call(env)
      begin
        env[Tzispa::ENV_TZISPA_APP] = @application
        env[Tzispa::ENV_TZISPA_CONTEXT] = Tzispa::Http::Context.new(env)
        @builder.call(env)
      rescue => ex
        @application.logger.error "#{ex.message} (#{ex.class}):\n #{ex.backtrace&.join("\n\t")}"
        env[Tzispa::ENV_TZISPA_CONTEXT].response.status = 500
        env[Tzispa::ENV_TZISPA_CONTEXT].response.finish
      end
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

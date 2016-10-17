# frozen_string_literal: true

require 'tzispa/http/context'

module Tzispa

  class Middleware

    attr_reader :application, :stack

    def initialize(app)
      @stack = []
      @application = app
    end

    def builder
      midw = self
      @builder ||= ::Rack::Builder.new do
        #mw.load_default_stack
        midw.application.load!
        midw.stack.each { |m, args, block| use midw.load(m), *args, &block }
        run midw.application.routes.router
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
        application.load!
        #use TzispaEnv, app
      end
    end


  end
end

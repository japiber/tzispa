# frozen_string_literal: true

require 'rack'
require 'browser'

module Tzispa
  module Http
    class Request < Rack::Request

        alias secure? ssl?

        attr_reader :browser

        def initialize(env)
          super(env)
          @browser = Browser.new user_agent, accept_language: env["HTTP_ACCEPT_LANGUAGE"]
        end

        def forwarded?
          @env.include? "HTTP_X_FORWARDED_HOST"
        end

        def safe?
          get? or head? or options? or trace?
        end

        def idempotent?
          safe? or put? or delete? or link? or unlink?
        end

        def link?
          request_method == "LINK"
        end

        def unlink?
          request_method == "UNLINK"
        end

        alias secure? ssl?

    end
  end
end

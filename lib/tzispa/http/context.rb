require 'forwardable'
require 'tzispa/context'
require 'tzispa/http/response'
require 'tzispa/http/request'
require 'tzispa/http/session_flash_bag'
require 'tzispa/helpers/response'
require 'tzispa/helpers/security'

module Tzispa
  module Http

    class Context < Tzispa::Context
      extend Forwardable

      include Tzispa::Helpers::Response
      include Tzispa::Helpers::Security

      attr_reader    :request, :response
      def_delegators :@request, :session

      SESSION_LAST_ACCESS   = :__last_access
      SESSION_AUTH_USER     = :__auth__user
      GLOBAL_MESSAGE_FLASH  = :__global_message_flash


      def initialize(environment)
        super(environment)
        @request = Tzispa::Http::Request.new(environment)
        @response = Tzispa::Http::Response.new
      end

      def router_params
        @env['router.params']
      end

      def set_last_access
        session[SESSION_LAST_ACCESS] = Time.now.utc.iso8601
      end

      def last_access
        session[SESSION_LAST_ACCESS]
      end

      def flash
        SessionFlashBag.new(session, GLOBAL_MESSAGE_FLASH)
      end

      def logged?
        not session[SESSION_AUTH_USER].nil?
      end

      def login=(user)
        session[SESSION_AUTH_USER] = user if not user.nil?
      end

      def login
        session[SESSION_AUTH_USER]
      end

      def logout
        session.delete(SESSION_AUTH_USER)
      end

      def path(path_id, params={})
        @app.class.routes.path path_id, params
      end

      def api(handler, verb, predicate, sufix)
        raise ArgumentError.new('missing parameter in api call') unless handler && verb
        sign = sign_array [handler, verb, predicate], @app.config.salt
        @app.class.routes.path :api, {sign: sign, handler: handler, verb: verb, predicate: predicate, sufix: sufix}
      end

    end

  end
end

require 'forwardable'
require 'securerandom'
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
      def_delegators :@request, :session, :browser

      SESSION_LAST_ACCESS   = :__last_access
      SESSION_AUTH_USER     = :__auth__user
      GLOBAL_MESSAGE_FLASH  = :__global_message_flash


      def initialize(app, environment)
        super(app, environment)
        @request = Tzispa::Http::Request.new(environment)
        @response = Tzispa::Http::Response.new
        session[:id] ||= SecureRandom.uuid if app&.config&.sessions&.enabled
      end

      def router_params
        env['router.params'] || Hash.new
      end

      def layout
        router_params&.fetch(:layout, nil)
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

      def error_500(str)
        500.tap { |code|
          response.body = str if str
        }
      end

      def path(path_id, params={})
        app.routes.path path_id, params
      end

      def app_path(app_name, path_id, params={})
        app[app_name].routes.path path_id, params
      end

      def canonical_url(path_id, params={})
        app.config.canonical_url + path(path_id, params)
      end

      def app_canonical_url(app_name, path_id, params={})
        app[app_name].config.canonical_url + app_path(app_name, path_id, params)
      end

      def layout_path(layout, params={})
        params = params.merge(layout: layout) unless app.config.default_layout&.to_sym == layout
        app.routes.path layout, params
      end

      def app_layout_path(app_name, layout, params={})
        params = params.merge(layout: layout) unless app[app_name].config.default_layout&.to_sym == layout
        app[app_name].routes.path layout, params
      end

      def layout_canonical_url(layout, params={})
        app.config.canonical_url + layout_path(layout, params)
      end

      def app_layout_canonical_url(app_name, layout, params={})
        app[app_name].config.canonical_url + app_layout_path(app_name, layout, params)
      end

      def api(handler, verb, predicate, sufix, app_name)
        unless app_name
          canonical_url :api, handler: handler, verb: verb, predicate: predicate, sufix: sufix
        else
          app_canonical_url app_name, :api, handler: handler, verb: verb, predicate: predicate, sufix: sufix
        end
      end

      def sapi(handler, verb, predicate, sufix, app_name = nil)
        unless app_name
          sign = sign_array [handler, verb, predicate], app.config.salt
          canonical_url :sapi, sign: sign, handler: handler, verb: verb, predicate: predicate, sufix: sufix
        else
          sign = sign_array [handler, verb, predicate], app[:app_name].config.salt
          app_canonical_url app_name, :sapi, sign: sign, handler: handler, verb: verb, predicate: predicate, sufix: sufix
        end
      end

    end

  end
end

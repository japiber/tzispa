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
      def_delegators :@request, :session

      SESSION_LAST_ACCESS   = :__last_access
      SESSION_ID            = :__session_id
      SESSION_AUTH_USER     = :__auth__user
      GLOBAL_MESSAGE_FLASH  = :__global_message_flash


      def initialize(app, env)
        super(app, env)
        @request = Tzispa::Http::Request.new(env)
        @response = Tzispa::Http::Response.new
        init_session
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
        @flash ||= SessionFlashBag.new(session, GLOBAL_MESSAGE_FLASH)
      end

      def session?
        (not session[SESSION_ID].nil?) and (session[SESSION_ID] == session.id)
      end

      def logged?
        session? and (not session[SESSION_AUTH_USER].nil?)
      end

      def login=(user)
        session[SESSION_AUTH_USER] = user unless user.nil?
      end

      def login
        session[SESSION_AUTH_USER]
      end

      def logout
        session.delete(SESSION_AUTH_USER)
      end

      def login_redirect
        login_layout = config.login_layout
        redirect(layout_path(login_layout.to_sym), true, response) unless logged? || (layout == login_layout)
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

      def canonical_root
        @canonical_root ||= begin
          http_proto = Tzispa::Environment.instance.ssl? ? 'https://' : 'http://'
          http_host = Tzispa::Environment.instance.host
          http_port = if Tzispa::Environment.instance.ssl?
            ":#{Tzispa::Environment.instance.port}" unless Tzispa::Environment.instance.port == 443
          else
            ":#{Tzispa::Environment.instance.port}" unless Tzispa::Environment.instance.port == 80
          end
          "#{http_proto}#{http_host}#{http_port}"
        end
      end

      def canonical_url(path_id, params={})
        "#{canonical_root}#{path(path_id, params)}"
      end

      def app_canonical_url(app_name, path_id, params={})
        "#{canonical_root}#{app_path(app_name, path_id, params)}"
      end

      def layout_path(layout, params={})
        params = normalize_format(params.merge(layout: layout)) unless app.config.default_layout&.to_sym == layout
        app.routes.path layout, params
      end

      def app_layout_path(app_name, layout, params={})
        params = normalize_format(params.merge(layout: layout)) unless app[app_name].config.default_layout&.to_sym == layout
        app[app_name].routes.path layout, params
      end

      def layout_canonical_url(layout, params={})
        "#{canonical_root}#{layout_path(layout, params)}"
      end

      def app_layout_canonical_url(app_name, layout, params={})
        "#{canonical_root}#{app_layout_path(app_name, layout, params)}"
      end

      def api(handler, verb, predicate, sufix, app_name = nil)
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

      def path_sign?(sign, *args)
        sign == sign_array(args, config.salt)
      end

      def init_session
        generate_session_id if config&.sessions&.enabled and not session?
      end

      private

      def generate_session_id
        SecureRandom.uuid.tap { |uuid|
          session.id = uuid
          session[SESSION_ID] = uuid
        }
      end

      def normalize_format(params)
        params.tap { |pmm|
          pmm[:format] = config.default_format unless pmm[:format]
        }
      end

    end
  end
end

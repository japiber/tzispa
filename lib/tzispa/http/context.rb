# frozen_string_literal: true

require 'forwardable'
require 'tzispa/context'
require 'tzispa/http/response'
require 'tzispa/http/request'
require 'tzispa/helpers/response'
require 'tzispa/helpers/session'
require 'tzispa/helpers/security'

module Tzispa
  module Http

    class Context < Tzispa::Context
      extend Forwardable

      include Tzispa::Helpers::Response
      include Tzispa::Helpers::Security
      include Tzispa::Helpers::Session

      attr_reader    :request, :response
      def_delegators :@request, :session

      def initialize(app, env)
        super(app, env)
        @request = Request.new(env)
        @response = Response.new
        init_session
      end

      def request_method
        if request.request_method == 'POST' && request['_method']
          env[Request::REQUEST_METHOD] = request['_method']
          request['_method']
        else
          request.request_method
        end
      end

      def router_params
        env['router.params'] || {}
      end

      def layout
        router_params&.fetch(:layout, nil)
      end

      def login_redirect
        redirect(layout_path(config.login_layout.to_sym), true, response) if login_redirect?
      end

      def login_redirect?
        !logged? && (layout != config.login_layout)
      end

      def unauthorized_but_logged
        not_authorized unless logged?
      end

      def path(path_id, params = {})
        app.routes.path path_id, params
      end

      def app_path(app_name, path_id, params = {})
        app[app_name].routes.path path_id, params
      end

      def canonical_root
        @canonical_root ||= begin
          http_proto = Tzispa::Environment.instance.ssl? ? 'https://' : 'http://'
          http_host = Tzispa::Environment.instance.host
          http_port = Tzispa::Environment.instance.uri_port
          "#{http_proto}#{http_host}#{http_port}"
        end
      end

      def canonical_url(path_id, params = {})
        "#{canonical_root}#{path(path_id, params)}"
      end

      def app_canonical_url(app_name, path_id, params = {})
        "#{canonical_root}#{app_path(app_name, path_id, params)}"
      end

      def layout_path(layout, params = {})
        is_default = app.default_layout? layout
        params = normalize_format(params.merge(layout: layout)) unless is_default
        app.routes.path layout, params
      end

      def app_layout_path(app_name, layout, params = {})
        is_default = app[app_name].default_layout? == layout
        params = normalize_format(params.merge(layout: layout)) unless is_default
        app[app_name].routes.path layout, params
      end

      def layout_canonical_url(layout, params = {})
        "#{canonical_root}#{layout_path(layout, params)}"
      end

      def app_layout_canonical_url(app_name, layout, params = {})
        "#{canonical_root}#{app_layout_path(app_name, layout, params)}"
      end

      def api(handler, verb, predicate = nil, sufix = nil, app_name = nil)
        if app_name
          app_canonical_url app_name, :api, handler: handler, verb: verb,
                                            predicate: predicate, sufix: sufix
        else
          canonical_url :api, handler: handler, verb: verb,
                              predicate: predicate, sufix: sufix
        end
      end

      def sapi(handler, verb, predicate = nil, sufix = nil, app_name = nil)
        if app_name
          sign = sign_array [handler, verb, predicate], app[:app_name].config.salt
          app_canonical_url app_name, :sapi, sign: sign, handler: handler,
                                             verb: verb, predicate: predicate, sufix: sufix
        else
          sign = sign_array [handler, verb, predicate], app.config.salt
          canonical_url :sapi, sign: sign, handler: handler,
                               verb: verb, predicate: predicate, sufix: sufix
        end
      end

      def path_sign?(sign, *args)
        sign == sign_array(args, config.salt)
      end

      private

      def normalize_format(params)
        params.tap { |pmm| pmm[:format] = config.default_format unless pmm[:format] }
      end
    end

  end
end

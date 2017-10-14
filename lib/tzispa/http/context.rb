# frozen_string_literal: true

require 'forwardable'
require 'tzispa/context'
require 'tzispa/http/response'
require 'tzispa/http/request'
require 'tzispa_helpers'

module Tzispa
  module Http

    class Context < Tzispa::Context
      extend Forwardable

      include Tzispa::Helpers::Response
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

      def error_log(ex, status = nil)
        logger.error "E [#{request.ip}] #{request.request_method} #{request.fullpath} #{status || response.status}\n#{ex.backtrace.first}: #{ex.message} (#{ex.class})\n#{ex.backtrace.drop(1).map { |s| "\t#{s}" }.join("\n") }"
      end

      def info_log(ex, status = nil)
        logger.info "I [#{request.ip}] #{request.request_method} #{request.fullpath} #{status || response.status}\n#{ex.backtrace.first}: #{ex.message} (#{ex.class})\n#{ex.backtrace.drop(1).map { |s| "\t#{s}" }.join("\n") }"
      end

      private

      def normalize_format(params)
        params.tap { |pmm| pmm[:format] = config.default_format unless pmm[:format] }
      end
    end

  end
end

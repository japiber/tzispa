# frozen_string_literal: true

require 'rack'

module Tzispa
  module Http

    class Request < Rack::Request
      ALLOWED_HTTP_VERSIONS = ['HTTP/1.1', 'HTTP/2.0'].freeze

      HTTP_X_FORWARDED_HOST = 'HTTP_X_FORWARDED_HOST'

      REQUEST_METHOD = Rack::REQUEST_METHOD

      alias secure? ssl?

      def forwarded?
        env.include? HTTP_X_FORWARDED_HOST
      end

      def http_version
        env['HTTP_VERSION']
      end

      def allowed_http_version?
        ALLOWED_HTTP_VERSIONS.include? http_version
      end

      def safe?
        get? || head? || options? || trace?
      end

      def idempotent?
        safe? || put? || delete? || link? || unlink?
      end

      def link?
        request_method == 'LINK'
      end

      def unlink?
        request_method == 'UNLINK'
      end
    end

  end
end

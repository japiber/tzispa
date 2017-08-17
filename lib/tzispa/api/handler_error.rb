# frozen_string_literal: true

require 'i18n'
require 'tzispa/utils/string'

module Tzispa
  module Api
    module HandlerError

      using Tzispa::Utils::TzString

      HANDLER_OK = :ok

      def error?
        @error && @error != HANDLER_OK
      end

      def error_message
        I18n.t(error_id, default: error.to_s) if error
      end

      def error_id
        "#{self.class.name.dottize}.#{error}" if error
      end

      def http_bad_request(code = nil)
        error_status code || :bad_request, 400
      end

      def http_unauthorized(code = nil)
        error_status code || :unauthorized, 401
      end

      def http_forbidden(code = nil)
        error_status code || :forbidden, 403
      end

      def http_not_found(code = nil)
        error_status code || :not_found, 404
      end

      def http_not_aceptable(code = nil)
        error_status code || :not_acceptable, 406
      end

      def http_conflict(code = nil)
        error_status code || :conflict, 409
      end

      def http_gone(code = nil)
        error_status code || :gone, 410
      end

      def http_token_required(code = nil)
        error_status code || :token_required, 499
      end

      def http_server_error(code = nil)
        error_status code || :internal_server_error, 500
      end

      def http_not_implemented(code = nil)
        error_status code || :not_implemented, 501
      end

      def http_bad_gateway(code = nil)
        error_status code || :bad_gateway, 502
      end

      def http_service_unavailable(code = nil)
        error_status code || :service_unavailable, 503
      end

    end
  end
end

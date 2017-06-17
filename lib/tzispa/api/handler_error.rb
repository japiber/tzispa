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

      def message
        I18n.t(error_id, default: error.to_s) if error
      end

      def error_id
        "#{self.class.name.dottize}.#{error}" if error
      end

      def http_bad_request(error = nil)
        error_status error || :bad_requuest, 400
      end

      def http_unauthorized(error = nil)
        error_status error || :unauthorized, 401
      end

      def http_forbidden(error = nil)
        error_status error || :forbidden, 403
      end

      def http_not_found(error = nil)
        error_status error || :not_found, 404
      end

      def http_not_aceptable(error = nil)
        error_status error || :not_acceptable, 406
      end

      def http_conflict(error = nil)
        error_status error || :conflict, 409
      end

      def http_gone(error = nil)
        error_status error || :gone, 410
      end

      def http_token_required(error = nil)
        error_status error || :token_required, 499
      end

      def http_server_error(error = nil)
        error_status error || :internal_server_error, 500
      end

      def http_not_implemented(error = nil)
        error_status error || :not_implemented, 501
      end

      def http_bad_gateway(error = nil)
        error_status error || :bad_gateway, 502
      end

      def http_service_unavailable(error = nil)
        error_status error || :service_unavailable, 503
      end

    end
  end
end

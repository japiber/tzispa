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

      def error_log(error)
        context.logger.error "#{error}\n\n#{error.backtrace if error.respond_to?(:backtrace)}"
      end

      def http_bad_request(msg = nil)
        error_status msg || :bad_request, 400
      end

      def http_unauthorized(msg = nil)
        error_status msg || :unauthorized, 401
      end

      def http_forbidden(msg = nil)
        error_status msg || :forbidden, 403
      end

      def http_not_found(msg = nil)
        error_status msg || :not_found, 404
      end

      def http_not_aceptable(msg = nil)
        error_status msg || :not_acceptable, 406
      end

      def http_conflict(msg = nil)
        error_status msg || :conflict, 409
      end

      def http_gone(msg = nil)
        error_status msg || :gone, 410
      end

      def http_token_required(msg = nil)
        error_status msg || :token_required, 499
      end

      def http_server_error(msg = nil)
        error_status msg || :internal_server_error, 500
      end

      def http_not_implemented(msg = nil)
        error_status msg || :not_implemented, 501
      end

      def http_bad_gateway(msg = nil)
        error_status msg || :bad_gateway, 502
      end

      def http_service_unavailable(msg = nil)
        error_status msg || :service_unavailable, 503
      end

    end
  end
end

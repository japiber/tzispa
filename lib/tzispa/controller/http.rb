require 'forwardable'
require 'tzispa_helpers'
require 'tzispa/controller/base'
require 'tzispa/http/context'

module Tzispa
  module Controller

    class Http < Tzispa::Controller::Base
      extend Forwardable

      include Tzispa::Helpers::ErrorView

      attr_reader :custom_errors
      def_delegators :@context, :request, :response, :config

      def initialize(app, callmethod, context_class = Tzispa::Http::Context, custom_errors = true)
        super app, callmethod, context_class
        @custom_errors = custom_errors
      end

      def call(env)
        super
        response.finish
      end

      private

      def invoke
        prepare_response super
      rescue StandardError, ScriptError, SecurityError => ex
        prepare_response(500, error: ex)
      end

      def prepare_response(status, error: nil)
        response.status = status if status.is_a?(Integer)
        if context.client_error?
          prepare_client_error(status, error)
        elsif context.server_error?
          prepare_server_error(status, error)
        end
      end

      def prepare_client_error(status, error = nil)
        status.tap do |code|
          context.info_log(error, code) if error
          response.body = error_page(context.domain, status: code) if custom_errors
        end
      end

      def prepare_server_error(status, error = nil)
        status.tap do |code|
          context.error_log(error, code) if error
          if custom_errors
            response.body = if error && Tzispa::Environment.development?
                              debug_info(error)
                            else
                              error_page(context.domain, status: code)
                            end
          end
        end
      end

    end

  end
end

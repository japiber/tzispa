require 'forwardable'

module Tzispa
  module Api
    class Handler
      extend Forwardable

      def_delegators :@context, :request, :response, :app

      attr_reader :context, :status, :response_verb, :data

      HANDLED_UNDEFINED         = nil
      HANDLED_OK                = 1
      HANDLED_MISSING_PARAMETER = 98
      HANDLED_ERROR             = 99
      HANDLED_RESULT            = 200

      HANDLED_MESSAGES = {
        HANDLED_OK                => 'La operación se ha realizado correctamente'.freeze,
        HANDLED_MISSING_PARAMETER => 'Error: faltan parámetros para realizar la operación'.freeze,
        HANDLED_ERROR             => 'Error indeterminado: la operación no se ha podido realizar'.freeze
      }

      def initialize(context)
        @context = context
      end

      def result(response_verb:, status: HANDLED_UNDEFINED, data: nil)
        @status = status
        @response_verb = response_verb
        @data = data
      end

      def message
        if @status.nil?
          nil
        elsif @status >= HANDLED_OK && @status <= HANDLED_ERROR
          HANDLED_MESSAGES[@status]
        elsif @status > HANDLED_ERROR && @status < HANDLED_RESULT
          error_message @status
        elsif @status > HANDLED_RESULT
          result_messages @status
        else
          nil
        end
      end

      private

      def result_messages(status)
        self.class::RESULT_MESSAGES[status] if (defined?( self.class::RESULT_MESSAGES ) && self.class::RESULT_MESSAGES.is_a?(Hash))
      end

      def error_message(status)
        self.class::ERROR_MESSAGES[status] if (defined?( self.class::ERROR_MESSAGES ) && self.class::ERROR_MESSAGES.is_a?(Hash))
      end


    end
  end
end

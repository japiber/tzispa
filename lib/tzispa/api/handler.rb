# frozen_string_literal: true

require 'forwardable'
require 'json'
require 'tzispa/helpers/provider'
require 'tzispa/helpers/sign_requirer'

module Tzispa
  module Api

    class ApiException < StandardError; end
    class UnknownHandlerVerb < ApiException
      def initialize(s, name)
        super("Unknown verb: '#{s}' called in api handler '#{name}'")
      end
    end
    class InvalidSign < ApiException; end

    class Handler
      include Tzispa::Helpers::Provider
      include Tzispa::Helpers::SignRequirer
      extend Forwardable

      attr_reader :context, :response_verb, :data, :status
      def_delegators :@context, :request, :response, :app, :repository, :config

      HANDLED_UNDEFINED         = nil
      HANDLED_OK                = 1
      HANDLED_MISSING_PARAMETER = 98
      HANDLED_ERROR             = 99
      HANDLED_RESULT            = 200

      HANDLED_MESSAGES = {
        HANDLED_OK                => 'La operación se ha realizado correctamente',
        HANDLED_MISSING_PARAMETER => 'Error: faltan parámetros para realizar la operación',
        HANDLED_ERROR             => 'Error indeterminado: la operación no se ha podido realizar'
      }

      def initialize(context)
        @context = context
      end

      def result(response_verb:, status: nil, data: nil, error: nil)
        @status = status if status
        @response_verb = response_verb
        @data = data
        @error = error
      end

      def result_json(status: nil, data: nil, error: nil)
        result response_verb: :json, status: status, data: data.to_json, error: error
      end

      def message
        case status
        when status >= HANDLED_OK && status <= HANDLED_ERROR
          HANDLED_MESSAGES[status]
        when status > HANDLED_ERROR && status < HANDLED_RESULT
          error_message status
        when status > HANDLED_RESULT
          result_messages status
        end
      end

      def call(verb, predicate=nil)
        raise UnknownHandlerVerb.new(verb, self.class.name) unless provides? verb
        raise InvalidSign.new if sign_required? && !sign_valid?
        # process compound predicates
        args = predicate ? predicate.split(',') : nil
        send verb, *args
      end

      def set_status(value)
        @status = value
      end


      protected

      def static_path_sign?
        context.path_sign? context.router_params[:sign], context.router_params[:handler], context.router_params[:verb], context.router_params[:predicate]
      end

      private

      def result_messages(status)
        self.class::RESULT_MESSAGES[status] if (defined?( self.class::RESULT_MESSAGES ) && self.class::RESULT_MESSAGES.is_a?(Hash))
      end

      def error_message(status)
        "#{self.class::ERROR_MESSAGES[status]}#{': '+@error.to_s if @error}" if (defined?( self.class::ERROR_MESSAGES ) && self.class::ERROR_MESSAGES.is_a?(Hash))
      end


    end
  end
end

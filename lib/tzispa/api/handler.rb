# frozen_string_literal: true

require 'forwardable'
require 'json'
require 'i18n'
require 'tzispa/helpers/provider'
require 'tzispa/helpers/sign_requirer'
require 'tzispa/utils/string'

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

      using Tzispa::Utils

      attr_reader :context, :response_verb, :data, :status
      def_delegators :@context, :request, :response, :app, :repository, :config, :logger

      HANDLER_STATUS_UNDEFINED  = nil
      HANDLER_STATUS_OK         = :ok
      HANDLER_MISSING_PARAMETER = :missing_parameter


      def initialize(context)
        @context = context
      end

      def result(response_verb:, data: nil, status: HANDLER_STATUS_UNDEFINED)
        @response_verb = response_verb
        @status = status if status
        @data = data
      end

      def error?
        status && status != HANDLER_STATUS_OK
      end

      def result_json(data, status: nil)
        result response_verb: :json, data: data, status: status
      end

      def result_download(data, status: nil)
        result response_verb: :download, data: data, status: status
      end

      def not_found
        result response_verb: :not_found
      end

      def message
        I18n.t("#{self.class.name.dottize}.#{status}", default: "#{status}") if status
      end

      def run!(verb, predicate=nil)
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


    end
  end
end

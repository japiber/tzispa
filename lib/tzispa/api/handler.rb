# frozen_string_literal: true

require 'forwardable'
require 'tzispa/helpers/provider'
require 'tzispa/helpers/sign_requirer'
require 'tzispa/helpers/hooks/before'
require 'tzispa/helpers/hooks/after'
require_relative 'handler_error'

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
      extend Forwardable

      include Tzispa::Api::HandlerError
      include Tzispa::Helpers::Provider
      include Tzispa::Helpers::SignRequirer
      include Tzispa::Helpers::Hooks::Before
      include Tzispa::Helpers::Hooks::After

      using Tzispa::Utils::TzString

      attr_reader :context, :type, :data, :error, :rescue_hook, :status
      def_delegators :@context, :request, :response, :app, :repository,
                     :config, :logger, :unauthorized_but_logged, :login_redirect

      def initialize(context)
        @context = context
        @error = nil
        @status = nil
        @rescue_hook = nil
      end

      def result(type:, data: nil)
        @type = type
        @data = data
      end

      def result_json(data)
        result type: :json, data: data
      end

      def result_download(data)
        result type: :download, data: data
      end

      def result_redirect(data)
        result type: :redirect, data: data
      end

      def error_status(error_code, http_status = nil)        
        @error = error_code
        @status = http_status
        result_json error_message: error_message
      end
      # alias result_error error_status

      def on_error(http_error, error_code = nil, logger = nil)
        @rescue_hook = { logger: logger, error_code: error_code, http_error: http_error }
      end

      def run!(verb, predicate = nil)
        raise UnknownHandlerVerb.new(verb, self.class.name) unless provides? verb
        raise InvalidSign if sign_required? && !sign_valid?
        do_before
        begin
          send verb, *(predicate&.split(','))
        rescue => err
          if rescue_hook
            send(rescue_hook[:logger], err) if rescue_hook.include? :logger
            send(rescue_hook[:http_error], rescue_hook[:error_code])
          else
            raise
          end
        end
        do_after
      end

      def redirect_url(url)
        if url && !url.strip.empty?
          url.start_with?('#') ? "#{request.referer}#{url}" : url
        else
          request.referer
        end
      end

      protected

      def static_path_sign?
        context.path_sign? context.router_params[:sign],
                           context.router_params[:handler],
                           context.router_params[:verb],
                           context.router_params[:predicate]
      end
    end

  end
end

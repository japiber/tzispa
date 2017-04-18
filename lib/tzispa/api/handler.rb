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
      extend Forwardable

      include Tzispa::Helpers::Provider
      include Tzispa::Helpers::SignRequirer

      using Tzispa::Utils::TzString

      attr_reader :context, :type, :data, :error, :status
      def_delegators :@context, :request, :response, :app, :repository,
                     :config, :logger, :unauthorized_but_logged, :login_redirect

      attr_writer :error

      HANDLER_OK                = :ok
      HANDLER_MISSING_PARAMETER = :missing_parameter

      def initialize(context)
        @context = context
        @error = nil
        @status = nil
      end

      class << self
        def before(*args)
          (@before_chain ||= []).tap do |bef|
            args.each do |s|
              s = s.to_sym
              bef << s unless bef.include?(s)
            end
          end
        end
      end

      def error?
        @error && @error != HANDLER_OK
      end

      def error_status(error, status = nil)
        @error = error
        @status = status
      end

      def result(type:, data: nil, error: nil)
        @type = type
        @data = data
        @error = error if error
      end

      def result_json(data)
        result type: :json, data: data
      end

      def result_download(data)
        result type: :download, data: data
      end

      def not_found
        result type: :not_found
      end

      def message
        I18n.t(error_id, default: error.to_s) if error
      end

      def error_id
        "#{self.class.name.dottize}.#{error}" if error
      end

      def run!(verb, predicate = nil)
        raise UnknownHandlerVerb.new(verb, self.class.name) unless provides? verb
        raise InvalidSign if sign_required? && !sign_valid?
        do_before
        # process compound predicates
        args = predicate ? predicate.split(',') : nil
        send verb, *args
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

      def do_before
        self.class.before.each { |hbef| send hbef }
      end
    end

  end
end

# frozen_string_literal: true

require 'json'
require 'tzispa/domain'
require 'tzispa/controller/base'
require 'tzispa/controller/exceptions'
require 'tzispa/helpers/response'
require 'tzispa/utils/string'

module Tzispa
  module Controller

    class ControllerException < StandardError; end

    class Api < Base
      using Tzispa::Utils::TzString

      include Tzispa::Helpers::Response

      def initialize(app, callmethod = :dispatch!)
        super(app, callmethod, false)
      end

      def dispatch!
        verb = context.router_params[:verb]
        predicate = context.router_params[:predicate]
        handler = prepare_handler
        handler.run! verb, predicate
        send(handler.type || :empty, handler)
      end

      def prepare_handler
        self.class.handler_class(request_method, domain, handler_name).new(context)
      end

      def domain
        _, domain_name = context.router_params[:handler].split('.').reverse
        domain_name ? Tzispa::Domain.new(name: domain_name) : context.app.domain
      end

      def handler_name
        context.router_params[:handler].split('.').last
      end

      def handler_redirect_url(url)
        if url && !url.strip.empty?
          url.start_with?('#') ? "#{request.referer}#{url}" : url
        else
          request.referer
        end
      end

      def empty(handler)
        api_response handler.status
      end

      def redirect(handler)
        api_flash(handler.message) if handler.error?
        context.redirect handler.redirect_url(handler.data), config.absolute_redirects, response
      end

      def html(handler)
        content = handler.data unless handler.error?
        api_response handler.status, content, :htm
      end

      def json(handler)
        content = handler.data.is_a?(::String) ? JSON.parse(handler.data) : handler.data.to_json        
        api_response handler.status, content, :json
      end

      def text(handler)
        content = handler.data unless handler.error?
        api_response handler.status, content, :text
      end

      def download(handler)
        send_file handler.data[:path], handler.data
      end

      def api_flash(message)
        context.flash << message if config.sessions&.enabled
      end

      def api_response(status, content = nil, type = nil)
        content_type(type) if type
        response.body = content if content
        response.status = status if status
      end

      def request_method
        context.request_method.downcase
      end

      class << self
        def handler_class_name(handler_name)
          "#{handler_name.camelize}Handler"
        end

        def handler_class_file(domain, handler_name, request_method)
          "#{domain.path}/api/#{request_method}/#{handler_name}.rb"
        end

        def handler_namespace(domain, request_method)
          "#{domain.name.to_s.camelize}::Api::#{request_method.capitalize}"
        end

        def handler_class(request_method, domain, handler_name)
          domain.require "api/#{request_method}/#{handler_name}"
          "#{handler_namespace domain, request_method}::#{handler_class_name handler_name}"
            .constantize
        end
      end
    end

  end
end

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
      using Tzispa::Utils

      include Tzispa::Helpers::Response

      def dispatch!
        verb = context.router_params[:verb]
        predicate = context.router_params[:predicate]
        handler = prepare_handler
        handler.run! verb, predicate
        send(handler.response_verb, handler) if handler.response_verb
        response.finish
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

      def redirect(handler)
        url = if handler.data && !handler.data.strip.empty?
                handler.data.start_with?('#') ? "#{request.referer}#{handler.data}" : handler.data
              else
                request.referer
              end
        context.flash << handler.message if config.sessions&.enabled && handler.error?
        context.redirect url, config.absolute_redirects, response
      end

      def html(handler)
        content_type :htm
        context.flash << handler.message if config.sessions&.enabled && handler.error?
        response.body << handler.data
        set_api_headers handler.status
      end

      def json(handler)
        content_type :json
        data = handler.data.is_a?(::String) ? JSON.parse(handler.data) : handler.data.to_json
        response.body << if handler.error?
                           Hash[:__error, true,
                                :__error_msg, handler.message,
                                :__error_code, handler.status].to_json
                         else
                           data
                         end
        set_api_headers handler.status
      end

      def text(handler)
        content_type :text
        context.flash << handler.message if config.sessions&.enabled && handler.error?
        response.body << handler.data
        api_headers handler.status
      end

      def download(handler)
        send_file handler.data[:path], handler.data
      end

      def request_method
        context.request_method.downcase
      end

      class << self
        def handler_class_name(handler_name)
          "#{handler_name.camelize}Handler"
        end

        def handler_class_file(domain, handler_name)
          "#{domain.path}/api/#{handler_name}.rb"
        end

        def handler_namespace(domain, request_method)
          "#{domain.name.to_s.camelize}::Api::#{request_method.capitalize}"
        end

        def handler_class(request_method, domain, handler_name)
          domain.require "api/#{request_method}/#{handler_name}"
          "#{handler_namespace domain, request_method}::#{handler_class_name handler_name}"
            .constantize
        end

        def generate_handler(domain, name)
          raise "The handler '#{name}' already exist" if File.exist?(handler_class_file)
          File.open(handler_class_file(domain, name), 'w') do |f|
            handler_code = String.new
            f.puts handler_code.indenter("require 'tzispa/api/handler'\n\n")
            level = 0
            handler_namespace.split('::').each do |ns|
              f.puts handler_code.indenter("module #{ns}\n", level.positive? ? 2 : 0).to_s
              level += 1
            end
            f.puts handler_code.indenter("\nclass #{handler_class_name} < Tzispa::Api::Handler\n\n", 2)
            f.puts handler_code.indenter("end\n\n")
            handler_namespace.split('::').each do |ns|
              f.puts handler_code.unindenter("end\n", 2)
            end
          end
        end
      end

      private

      def api_headers(status)
        handler = context.router_params[:handler]
        verb = context.router_params[:verb]
        predicate = context.router_params[:predicate]
        response['X-API'] = "#{handler}:#{verb}:#{predicate}"
        response['X-API-STATE'] = status&.to_s
      end

    end
  end
end

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
        handler_name, domain_name = context.router_params[:handler].split('.').reverse
        domain = domain_name.nil? ? context.app.domain : Tzispa::Domain.new(name: domain_name)
        verb = context.router_params[:verb]
        predicate = context.router_params[:predicate]
        handler = self.class.handler_class(domain, handler_name).new(context)
        handler.run! verb, predicate
        send(handler.response_verb, handler) if handler.response_verb
        response.finish
      end

      def redirect(handler)
        url = if handler.data && !handler.data.strip.empty?
          handler.data.start_with?('#') ? "#{request.referer}#{handler.data}" : handler.data
        else
          request.referer
        end
        puts "#{handler.error?} -> #{handler.message}"
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
        data = ::String === handler.data ? JSON.parse(handler.data) : handler.data.to_json
        response.body << data
        response.body << Hash[:__error, true, :__msg_error, handler.message].to_json if handler.error?
        set_api_headers handler.status
      end

      def text(handler)
        content_type :text
        context.flash << handler.message if config.sessions&.enabled && handler.error?
        response.body << handler.data
        set_api_headers handler.status
      end

      def download(handler)
        send_file handler.data[:path], handler.data
      end

      class << self

        def handler_class_name(handler_name)
          "#{handler_name.camelize}Handler"
        end

        def handler_class_file(domain, handler_name)
          "#{domain.path}/api/#{handler_name}.rb"
        end

        def handler_namespace(domain)
          "#{domain.name.to_s.camelize}::Api"
        end

        def handler_class(domain, handler_name)
          domain.require "api/#{handler_name}"
          "#{handler_namespace domain}::#{handler_class_name handler_name}".constantize
        end

        def generate_handler(domain, name)
          raise "The handler '#{name}' already exist" if File.exist?(handler_class_file)
          File.open(handler_class_file(domain, name), "w") { |f|
            handler_code = String.new
            f.puts handler_code.indenter("require 'tzispa/api/handler'\n\n")
            level = 0
            handler_namespace.split('::').each { |ns|
              f.puts handler_code.indenter("module #{ns}\n", level > 0 ? 2 : 0).to_s
              level += 1
            }
            f.puts handler_code.indenter("\nclass #{handler_class_name} < Tzispa::Api::Handler\n\n", 2)
            f.puts handler_code.indenter("end\n\n")
            handler_namespace.split('::').each { |ns|
              f.puts handler_code.unindenter("end\n", 2)
            }
          }
        end

      end

      private

      def set_api_headers(status)
        response['X-API'] = "#{context.router_params[:handler]}:#{context.router_params[:verb]}:#{context.router_params[:predicate]}"
        response['X-API-STATE'] = "#{status}"
      end

    end
  end
end

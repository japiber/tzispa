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
        handler.call verb, predicate
        send(handler.response_verb, handler) if handler.response_verb
        response.finish
      end

      def redirect(target)
        url = if target.data && !target.data.strip.empty?
          target.data.start_with?('#') ? "#{request.referer}#{target.data}" : target.data
        else
          request.referer
        end
        context.flash << target.message if config.sessions&.enabled
        context.redirect url, config.absolute_redirects, response
      end

      def html(content)
        content_type :htm
        response.body << content.data
        set_api_headers content.status
      end

      def json(content)
        content_type :json
        data = ::Hash === content.data || ::Array === content.data ? content.data : JSON.parse(content.data)
        response.body << data.to_json
        set_api_headers content.status
      end

      def text(content)
        content_type :text
        response.body << content.data
        set_api_headers content.status
      end

      def download(content)
        send_file content.data[:path], content.data
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
        response['X-API-STATE'] = "#{status.to_i}"
      end

    end
  end
end

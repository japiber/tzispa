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

      include Tzispa::Helpers::Response

      attr_reader :handler

      def self.generate_handler(domain, name)
        @domain = domain
        @handler_name = name
        raise "The handler '#{name}' already exist" if File.exist?(handler_class_file)
        File.open(handler_class_file, "w") { |f|
          handler_code = TzString.new
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


      def dispatch!
        @handler_name, domain_name = context.router_params[:handler].split('.').reverse
        @domain = domain_name.nil? ? context.app.domain : Tzispa::Domain.new(name: domain_name)
        @verb = context.router_params[:verb]
        @predicate = context.router_params[:predicate]
        @handler = handler_class.new(context)
        handler.send @verb, @predicate
        context.flash << handler.message
        send handler.response_verb if handler.response_verb
        response.finish
      end

      def redirect
        url = if handler.data && !handler.data.strip.empty?
          handler.data.start_with?('#') ? "#{request.referer}#{handler.data}" : handler.data
        else
          request.referer
        end
        context.redirect url, config.absolute_redirects, response
      end

      def html
        response.body << handler.data
        content_type :htm
        set_action_headers
      end

      def json
        if handler.data.is_a?(::Hash)
          data = handler.data
          data[:__result_status] = handler.status
          data[:__result_message] = handler.message
        else
          data = JSON.parse(handler.data)
        end
        response.body << data.to_json
        content_type :json
        set_action_headers
      end

      def text
        response.body << handler.data
        content_type :text
        set_action_headers
      end

      def download
        send_file handler.data[:path], handler.data
      end

      def handler_class_name
        "#{TzString.camelize @handler_name}Handler"
      end

      def handler_class_file
        "#{@domain.path}/api/#{@handler_name}.rb"
      end

      def handler_namespace
        "#{TzString.camelize @domain.name }::Api"
      end

      def handler_class
        @domain.require "api/#{@handler_name}"
        TzString.constantize "#{handler_namespace}::#{handler_class_name}"
      end


      private


      def set_action_headers
        response['X-API'] = "#{context.router_params[:sign]}:#{context.router_params[:handler]}:#{context.router_params[:verb]}:#{context.router_params[:predicate]}"
        response['X-API-STATE'] = "#{handler.status}"
      end

    end
  end
end

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


      def self.generate_handler(domain, name)
        raise "The handler '#{name}' already exist" if File.exist?(handler_class_file)
        File.open(handler_class_file(domain, name), "w") { |f|
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
        handler_name, domain_name = context.router_params[:handler].split('.').reverse
        domain = domain_name.nil? ? context.app.domain : Tzispa::Domain.new(name: domain_name)
        verb = context.router_params[:verb]
        predicate = context.router_params[:predicate]
        handler = self.class.handler_class(domain, handler_name).new(context)
        handler.call verb, predicate
        context.flash << handler.message
        send(handler.response_verb, handler) if handler.response_verb
        response.finish
      end

      def redirect(target)
        url = if target.data && !target.data.strip.empty?
          target.data.start_with?('#') ? "#{request.referer}#{target.data}" : target.data
        else
          request.referer
        end
        context.redirect url, config.absolute_redirects, response
      end

      def html(content)
        response.body << content.data
        content_type :htm
        set_action_headers content.status
      end

      def json(content)
        data = content.data.respond_to?(:to_json) ? content.data : JSON.parse(content.data)
        response.body << data.to_json
        content_type :json
        set_action_headers content.status
      end

      def text(content)
        response.body << content.data
        content_type :text
        set_action_headers content.status
      end

      def download(content)
        send_file content.data[:path], content.data
      end

      class << self

        def handler_class_name(handler_name)
          "#{TzString.camelize handler_name}Handler"
        end

        def handler_class_file(domain, handler_name)
          "#{domain.path}/api/#{handler_name}.rb"
        end

        def handler_namespace(domain)
          "#{TzString.camelize domain.name }::Api"
        end

        def handler_class(domain, handler_name)
          domain.require "api/#{handler_name}"
          TzString.constantize "#{handler_namespace domain}::#{handler_class_name handler_name}"
        end

      end

      private

      def set_action_headers(status)
        response['X-API'] = "#{context.router_params[:sign]}:#{context.router_params[:handler]}:#{context.router_params[:verb]}:#{context.router_params[:predicate]}"
        response['X-API-STATE'] = "#{status}"
      end

    end
  end
end

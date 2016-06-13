# frozen_string_literal: true

require 'json'
require 'tzispa/domain'
require 'tzispa/controller/base'
require 'tzispa/controller/exceptions'
require 'tzispa/helpers/security'
require 'tzispa/helpers/response'
require 'tzispa/utils/string'


module Tzispa
  module Controller
    class Api < Base

      include Tzispa::Helpers::Security
      include Tzispa::Helpers::Response

      attr_reader :hnd

      def self.generate_handler(domain, name)
        @domain = domain
        @handler = name
        raise "The handler '#{name}' already exist" if File.exist?(handler_class_file)
        File.open(handler_class_file, "w") { |f|
          hnd_code = TzString.new
          f.puts hnd_code.indenter("require 'tzispa/api/handler'\n\n")
          level = 0
          handler_namespace.split('::').each { |ns|
            f.puts hnd_code.indenter("module #{ns}\n", level > 0 ? 2 : 0).to_s
            level += 1
          }
          f.puts hnd_code.indenter("\nclass #{handler_class_name} < Tzispa::Api::Handler\n\n", 2)
          f.puts hnd_code.indenter("end\n\n")
          handler_namespace.split('::').each { |ns|
            f.puts hnd_code.unindenter("end\n", 2)
          }
        }
      end


      def dispatch!
        raise Error::InvalidSign.new unless sign?
        @handler, domain_name = context.router_params[:handler].split('.').reverse
        @domain = domain_name.nil? ? context.app.domain : Tzispa::Domain.new(name: domain_name)
        @verb = context.router_params[:verb]
        @predicate = context.router_params[:predicate]
        @hnd = handler_class.new(context)
        @predicate ? hnd.send(@verb, @predicate) : hnd.send(@verb)
        send hnd.response_verb if hnd.response_verb
        response.finish
      end

      def redirect
        context.flash << hnd.message
        url = if hnd.data && !hnd.data.strip.empty?
          hnd.data.start_with?('#') ? "#{request.referer}#{hnd.data}" : hnd.data
        else
          request.referer
        end
        context.redirect url, config.absolute_redirects, response
      end

      def html
        context.flash << hnd.message
        response.body << hnd.data
        content_type :htm
        set_action_headers
      end

      def json
        if hnd.data.is_a?(::Hash)
          data = hnd.data
          data[:__result_status] = hnd.status
          data[:__result_message] = hnd.message
        else
          data = JSON.parse(hnd.data)
        end
        response.body << data.to_json
        content_type :json
        set_action_headers
      end

      def text
        context.flash << hnd.message
        response.body << hnd.data
        content_type :text
        set_action_headers
      end

      def download
        context.flash << hnd.message
        data = hnd.data
        path = "#{Dir.pwd}/#{data[:path]}"
        send_file path, data
      end

      def handler_class_name
        "#{TzString.camelize @handler}Handler"
      end

      def handler_class_file
        "#{@domain.path}/api/#{@handler}.rb"
      end

      def handler_namespace
        "#{TzString.camelize @domain.name }::Api"
      end

      def handler_class
        @domain.require "api/#{@handler}"
        TzString.constantize "#{handler_namespace}::#{handler_class_name}"
      end


      private


      def set_action_headers
        response['X-API'] = "#{context.router_params[:sign]}:#{context.router_params[:handler]}:#{context.router_params[:verb]}:#{context.router_params[:predicate]}"
        response['X-API-STATE'] = "#{hnd.status}"
      end

      def sign?
        context.router_params[:sign] == sign_array([
           context.router_params[:handler],
           context.router_params[:verb],
           context.router_params[:predicate]
          ],
          context.app.config.salt)
      end

    end
  end
end

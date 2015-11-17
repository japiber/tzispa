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

      def dispatch!
        raise Error::InvalidSign.new unless sign?
        @handler, domain_name = context.router_params[:handler].split('.').reverse
        @domain = domain_name.nil? ? context.app.domain : Tzispa::Domain.new(name: domain_name)
        @verb = context.router_params[:verb]
        @predicate = context.router_params[:predicate]
        hnd = handler_class.new(context)
        @predicate ? hnd.send(@verb, @predicate) : hnd.send(@verb)
        context.flash << hnd.message
        send hnd.response_verb, hnd.data
        response.finish
      end

      def redirect(url)
        context.redirect url, response
      end

      def html(body)
        response.body << body
        set_action_headers
      end

      def json(body)
        response.body << body
        content_type :json
        set_action_headers
      end

      def text(body)
        response.body << body
        content_type :text
        set_action_headers
      end

      def download(data)
        path = "#{Dir.pwd}/#{data[:path]}".freeze
        send_file path, data
      end

      private

      def set_action_headers
        response['X-API'] = "#{context.router_params[:sign]}:#{context.router_params[:handler]}:#{context.router_params[:verb]}:#{context.router_params[:predicate]}".freeze
      end

      def sign?
        context.router_params[:sign] == sign_array([
           context.router_params[:handler],
           context.router_params[:verb],
           context.router_params[:predicate]
          ],
          context.app.config.salt)
      end

      def handler_class_name
        "#{TzString.camelize @domain.name }::Api::#{TzString.camelize @handler }Handler".freeze
      end

      def handler_class
        @domain.require "api/#{@handler.downcase}"
        TzString.constantize handler_class_name
      end

    end
  end
end

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

      def dispatch!
        raise Error::InvalidSign.new unless sign?
        @handler, domain_name = context.router_params[:handler].split('.').reverse
        @domain = domain_name.nil? ? context.app.domain : Tzispa::Domain.new(name: domain_name)
        @verb = context.router_params[:verb]
        @predicate = context.router_params[:predicate]
        @hnd = handler_class.new(context)
        @predicate ? hnd.send(@verb, @predicate) : hnd.send(@verb)
        send hnd.response_verb
        response.finish
      end

      def redirect
        context.flash << hnd.message
        url = hnd.data
        context.redirect url, response
      end

      def html
        context.flash << hnd.message
        response.body << hnd.data
        content_type :htm
        set_action_headers
      end

      def json
        data = hnd.data.is_a?(::Hash) ? hnd.data : JSON.parse(hnd.data)
        data[:__result_status] = hnd.status
        data[:__result_message] = hnd.message
        response.body << data.to_json.to_s
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

      private

      attr_reader :hnd

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

      def handler_class_name
        "#{TzString.camelize @domain.name }::Api::#{TzString.camelize @handler }Handler"
      end

      def handler_class
        @domain.require "api/#{@handler.downcase}"
        TzString.constantize handler_class_name
      end

    end
  end
end

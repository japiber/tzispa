# frozen_string_literal: true

require 'forwardable'
require 'tzispa/helpers/error_view'
require 'tzispa/http/context'
require 'tzispa/environment'

module Tzispa
  module Controller

    class Base
      extend Forwardable

      include Tzispa::Helpers::ErrorView

      attr_reader :context, :application, :callmethod
      def_delegators :@context, :request, :response, :config,
                     :login_redirect, :unauthorized_but_logged

      def initialize(app, callmethod = nil)
        @callmethod = callmethod
        @application = app
      end

      def call(env)
        @context = Tzispa::Http::Context.new(@application, env)
        invoke if callmethod
        response.finish
      end

      class << self
        def before(*args)
          (@before_chain ||= []).tap do |bef|
            args&.each do |s|
              s = s.to_sym
              bef << s unless bef.include?(s)
            end
          end
        end
      end

      private

      def invoke
        prepare_response catch(:halt) {
          do_before
          send callmethod
        }
      rescue Tzispa::Rig::NotFound => ex
        prepare_client_error(404, ex)
      rescue StandardError, ScriptError, SecurityError => ex
        prepare_server_error(500, ex)
      end

      def prepare_response(status, content = nil)
        if response.client_error?
          prepare_client_error(status)
        elsif response.server_error?
          prepare_server_error(status)
        elsif content
          response.status = status if status.is_a?(Integer)
          response.body = content
        elsif status.is_a?(Integer)
          response.status = status
        end
      end

      def do_before
        self.class.before.each { |hook| send hook }
      end

      def prepare_client_error(status, error = nil)
        status.tap do |code|
          response.status = status if status.is_a?(Integer)
          context.logger.info log_format(code, error.to_s) if error
          response.body = error_page(context.domain, status: code)
        end
      end

      def prepare_server_error(status, error = nil)
        status.tap do |code|
          response.status = status if status.is_a?(Integer)
          context.logger.error log_format(code, error_log(error)) if error
          response.body = if error && Tzispa::Environment.development?
                            debug_info(error)
                          else
                            error_page(context.domain, status: code)
                          end
        end
      end

      def log_format(status, msg)
        String.new.tap do |str|
          str << "[#{context.request.ip} #{DateTime.now}] #{context.request.request_method}"
          str << " #{context.request.fullpath} #{status}\n#{msg}"
        end
      end
    end

  end
end

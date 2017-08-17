# frozen_string_literal: true

require 'forwardable'
require 'tzispa/helpers/error_view'
require 'tzispa/helpers/hooks/before'
require 'tzispa/helpers/hooks/after'
require 'tzispa/http/context'
require 'tzispa/environment'

module Tzispa
  module Controller

    class Base
      extend Forwardable

      include Tzispa::Helpers::ErrorView
      include Tzispa::Helpers::Hooks::Before
      include Tzispa::Helpers::Hooks::After

      attr_reader :context, :application, :callmethod, :custom_error
      def_delegators :@context, :request, :response, :config

      def initialize(app, callmethod = nil, custom_error = true)
        @callmethod = callmethod
        @application = app
        @custom_error = custom_error
      end

      def call(env)
        @context = Tzispa::Http::Context.new(@application, env)
        invoke if callmethod
        response.finish
      end

      private

      def invoke
        prepare_response catch(:halt) {
          do_before
          send callmethod
          do_after
        }
      rescue Tzispa::Rig::NotFound => ex
        prepare_response(404, error: ex)
      rescue StandardError, ScriptError, SecurityError => ex
        prepare_response(500, error: ex)
      end

      def prepare_response(status, error: nil)
        response.status = status if status.is_a?(Integer)
        if context.client_error?
          prepare_client_error(status, error)
        elsif context.server_error?
          prepare_server_error(status, error)
        end
      end

      def prepare_client_error(status, error = nil)
        status.tap do |code|
          context.info_log(error, code) if error
          response.body = error_page(context.domain, status: code) if custom_error
        end
      end

      def prepare_server_error(status, error = nil)
        status.tap do |code|
          context.error_log(error, code) if error
          if custom_error
            response.body = if error && Tzispa::Environment.development?
                              debug_info(error)
                            else
                              error_page(context.domain, status: code)
                            end
          end
        end
      end

    end

  end
end

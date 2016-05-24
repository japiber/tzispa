# frozen_string_literal: true

require 'forwardable'
require 'tzispa/version'
require 'tzispa/rig/template'
require 'tzispa/helpers/error_view'


module Tzispa
  module Controller

    class Base
      extend Forwardable

      include Tzispa::Helpers::ErrorView

      attr_reader :context
      def_delegators :@context, :request, :response, :config

      def initialize(callmethod=nil)
        @callmethod = callmethod
      end

      def call(environment)
        @context = environment[Tzispa::ENV_TZISPA_CONTEXT]
        invoke @callmethod if @callmethod
        response.finish
      end

      private

      def invoke(callmethod)
        debug_info = nil
        status = catch(:halt) {
          begin
            send "#{@callmethod}"
          rescue StandardError, ScriptError => exx
            debug_info = debug_info(exx) if config.developing
            500
          end
        }
        response.status = status if status.is_a?(Integer)
        if response.client_error?
          response.body = error_page(context.domain, status: response.status)
        elsif response.server_error?
          response.body = debug_info ?
            debug_info :
            error_page(context.domain, status: response.status)
        end
      end

    end

  end
end

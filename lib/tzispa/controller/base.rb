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
        status = catch(:halt) {
          begin
            send "#{@callmethod}"
          rescue StandardError, ScriptError => exx
            context.error_500( config.developing ? debug_info(exx) : nil )
          end
        }
        response.status = status if status.is_a?(Integer)
        if (response.client_error? || response.server_error?) && !config.developing
          response.body = error_page(context.domain)
        end
      end

    end

  end
end

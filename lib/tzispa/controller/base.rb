# frozen_string_literal: true

require 'forwardable'
require 'tzispa/version'
require 'tzispa/rig/template'


module Tzispa
  module Controller

    class Base
      extend Forwardable

      attr_reader :context
      def_delegators :@context, :request, :response, :config, :error

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
          send "#{@callmethod}"
        }
        response.status = status if status.is_a?(Integer)
        error context.app.error_page(response.status) if (response.client_error? || response.server_error?)
      end


    end

  end
end

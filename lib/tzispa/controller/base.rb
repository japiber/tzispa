# frozen_string_literal: true

require 'tzispa/helpers/hooks/before'
require 'tzispa/helpers/hooks/after'
require 'tzispa/environment'
require 'tzispa/context'

module Tzispa
  module Controller

    class Base

      include Tzispa::Helpers::Hooks::Before
      include Tzispa::Helpers::Hooks::After

      attr_reader :application, :context, :context_class, :callmethod, :custom_error

      def initialize(app, callmethod = nil, custom_error = true, context_class = Tzispa::Context)
        @callmethod = callmethod
        @application = app
        @custom_error = custom_error
        @context_class = context_class
      end

      def call(env)
        @context = context_class.new(application, env)
        invoke if callmethod
      end

      private

      def invoke
        catch(:halt) {
          do_before
          send callmethod
          do_after
        }
      end

    end

  end
end

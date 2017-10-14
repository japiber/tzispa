# frozen_string_literal: true

require 'tzispa_helpers'
require 'tzispa/environment'
require 'tzispa/context'

module Tzispa
  module Controller

    class Base

      include Tzispa::Helpers::Hooks::Before
      include Tzispa::Helpers::Hooks::After

      attr_reader :application, :context, :context_class, :callmethod

      def initialize(app, callmethod, context_class = Tzispa::Context)
        @application = app
        @callmethod = callmethod
        @context_class = context_class
      end

      def call(env)
        @context = context_class.new(application, env)
        invoke
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

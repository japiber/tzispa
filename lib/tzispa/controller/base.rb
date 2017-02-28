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

      attr_reader :context, :application
      def_delegators :@context, :request, :response, :config,
                     :login_redirect, :unauthorized_but_logged

      def initialize(app, callmethod = nil)
        @callmethod = callmethod
        @application = app
      end

      def call(env)
        @context = Tzispa::Http::Context.new(@application, env)
        invoke if @callmethod
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
          begin
            do_before
            send @callmethod
          rescue Tzispa::Rig::NotFound => ex
            context.logger.info "#{ex.message} (#{ex.class})"
            404
          rescue StandardError, ScriptError, SecurityError => ex
            context.logger.error error_log(ex)
            @dinfo = debug_info(ex) if Tzispa::Environment.development?
            500
          end
        }
      end

      def prepare_response(status)
        response.status = status if status.is_a?(Integer)
        if response.client_error?
          response.body = error_page(context.domain, status: response.status)
        elsif response.server_error?
          response.body = @dinfo || error_page(context.domain, status: response.status)
        end
      end

      def do_before
        self.class.before.each { |hbef| send hbef }
      end
    end

  end
end

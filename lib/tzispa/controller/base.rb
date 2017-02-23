# frozen_string_literal: true

require 'forwardable'
require 'tzispa/helpers/error_view'
require 'tzispa/http/context'


module Tzispa
  module Controller

    class Base
      extend Forwardable

      include Tzispa::Helpers::ErrorView

      attr_reader :context, :application
      def_delegators :@context, :request, :response, :config

      def initialize(app, callmethod=nil)
        @callmethod = callmethod
        @application = app
      end

      def call(env)
        @context = Tzispa::Http::Context.new(@application, env)
        invoke @callmethod if @callmethod
        response.finish
      end


      class << self
        def before(*args)
          (@before_chain ||= []).tap { |bef|
            args&.each { |s|
              s = s.to_sym
              bef << s unless bef.include?(s)
            }
          }
        end
      end

      private

      def invoke(callmethod)
        prepare_response catch(:halt) {
          begin
            do_before
            send "#{@callmethod}"
          rescue Tzispa::Rig::NotFound => ex
            context.logger.info "#{ex.message} (#{ex.class})"
            404
          rescue StandardError, ScriptError => ex
            context.logger.error "#{ex.message} (#{ex.class}):\n #{ex.backtrace.join("\n\t") if ex.respond_to?(:backtrace) && ex.backtrace}"
            @debug_info = debug_info(ex) if config.developing
            500
          end
        }
      end

      def prepare_response(status)
        response.status = status if status.is_a?(Integer)
        if response.client_error?
          response.body = error_page(context.domain, status: response.status)
        elsif response.server_error?
          response.body = @debug_info || error_page(context.domain, status: response.status)
        end
      end

      def do_before
        self.class.before.each { |hbef|
          send hbef
        }
      end

    end

  end
end

# frozen_string_literal: true

require 'forwardable'
require 'ostruct'
require 'tzispa/version'
require 'tzispa/http/context'
require 'tzispa/rig/template'


module Tzispa
  module Controller

    class Base
      extend Forwardable

      attr_reader :context
      def_delegators :@context, :request, :response, :config

      def initialize(callmethod)
        @callmethod = callmethod
      end

      def call(environment)
        @context = Tzispa::Http::Context.new(environment)
        invoke @callmethod
        response.finish
      end

      private

      def invoke(callmethod)
        status = catch(:halt) {
          begin
            send "#{@callmethod}"
          rescue StandardError, ScriptError => ex
            context.app.logger.error "#{ex.message}\n#{ex.backtrace.map { |trace| "\t #{trace}" }.join('\n') if ex.respond_to?(:backtrace) && ex.backtrace}"
            error error_report(ex)
          end
        }
        response.status = status if status.is_a?(Integer)
        error_page(response.status) if (response.client_error? || response.server_error?) && !config.developing
      end

      def error(body)
        500.tap { |code|
          response.status = code
          response.body = body
        }
      end

      def error_report(error=nil)
        text = String.new('<!DOCTYPE html>')
        text << '<html lang="es"><head>'
        text << '<meta charset="utf-8" />'
        text << '<style> html {background:#cccccc; font-family:Arial; font-size:15px; color:#555;} body {width:75%; max-width:1200px; margin:18px auto; background:#fff; border-radius:6px; padding:32px 24px;} ul{list-style:none; margin:0; padding:0;} li{font-style:italic; color:#666;} h1 {color:#2ECC71;} </style>'
        text << '</head><body>'
        text << "<h5>#{Tzispa::FRAMEWORK_NAME} #{Tzispa::VERSION}</h5>\n"
        if error && config.developing
          text << "<h1>#{error.class.name}</h1><h3>#{error.message}</h1>\n"
          text << '<ol>' + error.backtrace.map { |trace| "<li>#{trace}</li>\n" }.join + '</ol>' if error.respond_to?(:backtrace) && error.backtrace
        else
          text << "<h1>Error 500</h1>\n"
          text << "Se ha producido un error inesperado al tramitar la petición"
        end
        text << '</body></html>'
      end

      def error_page(status)
        begin
          error_file = "#{@app.domain.path}/error/#{status}.htm"
          response.body = Tzispa::Rig::File.new(error_file).load!.content
        rescue
          response.body = String.new('<!DOCTYPE html>')
          response.body << '<html lang="es"><head>'
          response.body << '<meta charset="utf-8" />'
          response.body << '<style> html {background:#cccccc; font-family:Arial; font-size:15px; color:#555;} body {width:75%; max-width:1200px; margin:18px auto; background:#fff; border-radius:6px; padding:32px 24px;} #main {margin:auto; } h1 {color:#2ECC71; font-size:4em; text-align:center;} </style>'
          response.body << '</head><body>'
          response.body << '<div id="main">'
          response.body << "<h5>#{Tzispa::FRAMEWORK_NAME} #{Tzispa::VERSION}</h5>\n"
          response.body << "<h1>Error #{status}</h1>\n"
          response.body << '</div>'
          response.body << '</body></html>'
        end
      end

    end

  end
end

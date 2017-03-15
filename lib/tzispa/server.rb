# frozen_string_literal: true

require 'rack'
require 'tzispa/environment'

module Tzispa
  # provides rack-based web server interface
  class Server < ::Rack::Server
    attr_reader :options

    def initialize
      @options = _extract_options
      setup
    end

    def start
      preload
      super
    end

    private

    def setup
      instance_eval 'load "./config/boot.rb"'
      @app = if code_reloading?
               puts 'Tzispa is booting server with code reloading'
               Shotgun::Loader.new(rackup_file)
             else
               puts 'Tzispa is booting server without code reloading'
               config = "Rack::Builder.new {( #{::File.read(rackup_file)}\n )}.to_app"
               instance_eval config, rackup_file
             end
    end

    def env
      @env ||= Tzispa::Environment.instance
    end

    def code_reloading?
      env.code_reloading?
    end

    def preload
      return unless code_reloading?
      Shotgun.enable_copy_on_write
      Shotgun.preload
    end

    def rackup_file
      env.rackup.to_s
    end

    def _extract_options
      {
        environment: env.environment,
        config:      rackup_file,
        Host:        env.server_host,
        Port:        env.server_port,
        AccessLog:   []
      }
    end
  end
end

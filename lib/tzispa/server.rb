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
      super
    end

    private

    def setup
      @app = inner_app
    end

    def rackup_file
      env.rackup.to_s
    end

    def inner_app
      content = "Rack::Builder.new {( #{::File.read(rackup_file)}\n )}.to_app"
      instance_eval content, rackup_file
    end

    def env
      @env ||= Tzispa::Environment.instance
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

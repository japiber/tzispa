# frozen_string_literal: true

require 'tzispa/config/yaml'

module Tzispa
  module Config

    class DbConfig
      attr_reader :env, :config

      CONFIG_FILENAME = 'database'

      def initialize(env)
        @cftime = nil
        @env = env.to_sym
      end

      def to_h
        load!
        config.to_h[env]&.to_h
      end

      def filename
        @filename ||= "config/#{CONFIG_FILENAME}.yml"
      end

      def load!
        if @cftime.nil?
          @cftime = File.ctime(filename)
        elsif @cftime != File.ctime(filename)
          @config = nil
          @cftime = File.ctime(filename)
        end
        @config ||= Tzispa::Config::Yaml.load(filename)
      end

      def create_default
        hcfg = {}.tap do |cfg|
          cfg['development'] = {}
          cfg['deployment'] = {}
          cfg['test'] = {}
        end
        Yaml.save(hcfg, filename)
      end
    end

  end
end

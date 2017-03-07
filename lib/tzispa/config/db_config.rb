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

      def load!
        if @cftime.nil?
          @cftime = File.ctime(filename)
        elsif @cftime != File.ctime(filename)
          @config = nil
          @cftime = File.ctime(filename)
        end
        @config ||= Tzispa::Config::Yaml.load(filename)
      end

      def filename
        DbConfig.filename
      end

      class << self
        def filename
          @filename ||= "config/#{CONFIG_FILENAME}.yml"
        end

        def create_default(path)
          hcfg = {}.tap do |cfg|
            cfg['development'] = {}
            cfg['deployment'] = {}
            cfg['test'] = {}
          end
          Yaml.save(hcfg, File.join(path, filename))
        end

        def add_repository(name, adapter, dbconn)
          hs = YAML.safe_load(File.open(filename))
          hs.each do |_, v|
            v[name] = {
              'adapter' => adapter,
              'database' => dbconn,
              'connection_validation' => 'No',
              'local' => 'Yes'
            }
          end
          Yaml.save(hs, filename)
        end
      end
    end

  end
end

# frozen_string_literal: true

require 'tzispa/config/yaml'
require 'tzispa/helpers/security'

module Tzispa
  module Config
    class AppConfig

      include Tzispa::Helpers::Security

      CONFIG_FILENAME = :appconfig

      attr_reader :domain, :cfname

      def initialize(domain, configname=nil)
        @domain = domain
        @cfname = configname || CONFIG_FILENAME
        @cftime = nil
      end

      def filename
        @filename ||= "#{domain.path}/config/#{cfname}.yml".freeze
      end

      def load!
        if @cftime.nil?
          @cftime = File.ctime(filename)
        else
          if @cftime != File.ctime(filename)
            @config = nil
            @cftime = File.ctime(filename)
          end
        end
        @config ||= Tzispa::Config::Yaml.load(filename)
      end

      def create_default(host:, layout: 'index', dev_mode: true, locale: 'en')
        hcfg = Hash.new.tap { |cfg|
          cfg[:id] = domain.name
          cfg[:default_layout] = layout
          cfg[:default_format] = 'htm'
          cfg[:host_name] = host
          cfg[:dev_mode] = dev_mode
          cfg[:default_encoding] = 'utf-8'
          cfg[:auth_required] = false
          cfg[:salt] = secret(24)
          cfg[:locales] = Hash.new.tap { |loc|
            loc[:preload] = true
            loc[:default] = locale
          }
          cfg[:sessions] = Hash.new.tap { |ses|
            ses[:enabled] = true
            ses[:timeout] = 3600
            ses[:secret] = secret(32)
          }
        }
        Tzispa::Config::Yaml.save(hcfg, filename)
      end


    end
  end
end

# frozen_string_literal: true

require 'tzispa/config/yaml'
require 'tzispa_helpers'

module Tzispa
  module Config
    class AppConfig
      include Tzispa::Helpers::Security

      CONFIG_FILENAME = :appconfig

      attr_reader :domain, :cfname

      def initialize(domain)
        @domain = domain
        @cftime = nil
      end

      def filename
        @filename ||= "config/#{domain.name}.yml"
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

      def create_default(default_layout, locale)
        hcfg = {}.tap do |cfg|
          cfg['default_layout'] = default_layout
          cfg['default_format'] = 'htm'
          cfg['default_encoding'] = 'utf-8'
          cfg['absolute_redirects'] = true
          cfg['salt'] = secret(24)
          cfg['secret'] = secret(36)
          cfg['locales'] = {}.tap do |loc|
            loc['preload'] = true
            loc['default'] = locale
          end
          cfg['logging'] = {}.tap do |log|
            log['enabled'] = true
            log['shift_age'] = 'daily'
          end
          cfg['sessions'] = {}.tap { |ses| ses['enabled'] = false }
        end
        Tzispa::Config::Yaml.save(hcfg, filename)
        load!
      end
    end

  end
end

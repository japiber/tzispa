# frozen_string_literal: true

require 'tzispa/config/yaml'
require 'tzispa/helpers/security'

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
        else
          if @cftime != File.ctime(filename)
            @config = nil
            @cftime = File.ctime(filename)
          end
        end
        @config ||= Tzispa::Config::Yaml.load(filename)
      end

      def create_default(host:, default_layout: 'index', locale: 'en')
        hcfg = Hash.new.tap { |cfg|
          cfg['id'] = domain.name
          cfg['default_layout'] = default_layout
          cfg['default_format'] = 'htm'
          cfg['host_name'] = host
          cfg['canonical_url'] = "http://#{host}"
          cfg['default_encoding'] = 'utf-8'
          cfg['auth_required'] = false
          cfg['salt'] = secret(24)
          cfg['secret'] = secret(36)
          cfg['temp_dir'] = 'tmp'
          cfg['locales'] = Hash.new.tap { |loc|
            loc['preload'] = true
            loc['default'] = locale
          }
          cfg['logging'] = Hash.new.tap { |log|
            log['enabled'] = true
            log['shift_age'] = 'daily'
          }
          cfg['sessions'] = Hash.new.tap { |ses|
            ses['enabled'] = true
            ses['timeout'] = 3600
            ses['store_path'] = 'data/session'
            ses['secret'] = secret(32)
          }
        }
        Tzispa::Config::Yaml.save(hcfg, filename)
        load!
      end


    end
  end
end

# frozen_string_literal: true

require 'tzispa/config/yaml'

module Tzispa
  module Config
    class AppConfig

      CONFIG_FILENAME = :appconfig

      def initialize(domain, configname=nil)
        @domain = domain
        @cfname = configname || CONFIG_FILENAME
        @cftime = nil
      end

      def filename
        @filename ||= "#{@domain.path}/config/#{@cfname}.yml".freeze
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


    end
  end
end

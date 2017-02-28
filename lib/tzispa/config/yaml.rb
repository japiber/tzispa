# frozen_string_literal: true

require 'yaml'
require 'tzispa/config/base'

module Tzispa
  module Config

    class Yaml < Tzispa::Config::Base
      def self.load(filename)
        params = YAML.safe_load(File.open(filename))
        parametrize params
      end

      def self.save(cfg, filename)
        File.open(filename, 'w') do |f|
          f.write cfg.to_yaml
        end
      end
    end

  end
end

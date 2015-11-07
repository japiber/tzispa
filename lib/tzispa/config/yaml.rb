require 'yaml'
require 'tzispa/config/base'

module Tzispa
  module Config
    class Yaml < Tzispa::Config::Base


      def self.load(filename)
        params =  YAML.load(File.open(filename))
        self.parametrize params
      end



    end
  end
end

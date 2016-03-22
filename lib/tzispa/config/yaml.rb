require 'yaml'
require 'tzispa/config/base'

module Tzispa
  module Config
    class Yaml < Tzispa::Config::Base


      def self.load(filename)
        params =  YAML.load(File.open(filename))
        self.parametrize params
      end

      def self.save(cfg, filename)
        File.open(filename, 'w') { |f|
           f.write cfg.to_yaml
        }        
      end



    end
  end
end

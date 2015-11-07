require 'sequel'

module Tzispa
  class DataAdapter

    def initialize(adapter_config)
      @config = adapter_config
      @adapters = Hash.new
      @config.each { |key,value|
        @adapters[key.to_sym] = Sequel.connect value
      }
    end

    def [](name=nil)
      @adapters[name ? name.to_sym : first]
    end

    def first
      @config.first[0].to_sym
    end

  end
end

require 'tzispa/utils/string'

module Tzispa
  class Repository

    attr_reader :root

    DEFAULT_REPO_ROOT = :repository

    def initialize(adapters, root = DEFAULT_REPO_ROOT)
      @adapters = adapters
      @root = root
      @repo = Hash.new
      @mutex = Mutex.new
    end

    def [](model, adapter=nil)
      adapter ||= @adapters.first
      km = self.class.key model, adapter
      @mutex.synchronize {
        @repo[km] || build(model, adapter)
      }
    end

    private

    def build(model, adapter)
      km = self.class.key model, adapter
      Sequel::Model.db = @adapters[adapter]
      require model_source(model, adapter)
      @repo[km] = self.class.model_class( model, adapter )
      @repo[km].db = @adapters[adapter]
      if !@repo[km].respond_to? :entity_class!
        @repo[km].send( :define_singleton_method, :entity_class!) {
          class_variable_defined?(:@@__entity_class) ?
            class_variable_get(:@@__entity_class) :
            class_variable_set(:@@__entity_class, TzString.constantize("#{self}Entity") )
        }
      end
      @repo[km].send( :define_method, :entity!) {
        instance_variable_defined?(:@__entity) ?
          instance_variable_get(:@__entity) :
          instance_variable_set(:@__entity, self.class.entity_class!.new(self))
      }
      @repo[km]
    end

    def model_source(model, adapter)
      "./#{root.to_s.downcase}/#{adapter}/#{model}".freeze
    end

    def self.key(model,adapter)
      "#{adapter}__#{model}".to_sym
    end

    def self.model_class(model, adapter)
      TzString.constantize "Repository::#{TzString.camelize adapter}::#{TzString.camelize model}"
    end

  end
end

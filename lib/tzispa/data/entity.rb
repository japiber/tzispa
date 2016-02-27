# frozen_string_literal: true

require 'tzispa/utils/string'

module Tzispa
  module Data
    module Entity

      def self.included(base)
        base.extend(ClassMethods)
      end

      def entity!
        @__entity || @__entity = self.class.entity_class.new(self)
      end

      module ClassMethods
        def entity_class
          class_variable_defined?(:@@__entity_class) ?
            class_variable_get(:@@__entity_class) :
            class_variable_set(:@@__entity_class, TzString.constantize("#{self}Entity") )
        end
      end

      #unless model_class.respond_to?(:entity_class!)
      #  model_class.send(:define_singleton_method, :entity_class) {
      #    class_variable_defined?(:@@__entity_class) ?
      #      class_variable_get(:@@__entity_class) :
      #      class_variable_set(:@@__entity_class, TzString.constantize("#{self}Entity") )
      #  }
      #end
      #model_class.send(:define_method, :entity!) {
      #  instance_variable_defined?(:@__entity) ?
      #    instance_variable_get(:@__entity) :
      #    instance_variable_set(:@__entity, self.class.entity_class!.new(self))
      #}

    end
  end
end

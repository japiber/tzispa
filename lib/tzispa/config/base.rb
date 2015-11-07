require 'ostruct'

module Tzispa
  module Config
    class Base < Struct

      def self.parametrize(params)
        self.new( *(params.keys.map { |k| k.to_sym })).new(*(params.values.map { |v|
          v.is_a?(Hash) ? self.parametrize(v) : v
        }))
      end

    end
  end
end

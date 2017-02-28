# frozen_string_literal: true

require 'tzispa/environment'

module Tzispa
  module Commands

    class Command
      def initialize(options)
        Tzispa::Environment.opts = options
        @environment = Tzispa::Environment.instance
      end

      private

      attr_reader :environment
    end

  end
end
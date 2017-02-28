# frozen_string_literal: true

require 'tzispa/commands/command'

module Tzispa
  module Commands

    class Server < Command
      def initialize(options)
        super(options)

        require 'tzispa/server'
        @server = Tzispa::Server.new
      end

      def start
        server.start
      end

      protected

      attr_reader :server
    end

  end
end
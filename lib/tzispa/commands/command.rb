# frozen_string_literal: true

require 'tzispa/environment'

module Tzispa
  module Commands

    class Command

      NO_PROJECT_FOLDER = 'You must be located in a Tzispa project folder to run this command'

      def initialize(options)
        raise NO_PROJECT_FOLDER unless project_folder?
        Tzispa::Environment.opts = options
        @environment = Tzispa::Environment.instance
      end

      protected

      attr_reader :environment

      def project_folder?
        File.exist?(Tzispa::Environment::DEFAULT_RACKUP)
      end
    end

  end
end

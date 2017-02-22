require 'tzispa/controller/api'

module Tzispa
  module Commands

    class Api

      attr_reader :name, :domain

      def initialize(name, app)
        @prj = Project.open
        raise "Application '#{app}' does not exists in project file" unless @prj.apps.include?(app)
        @domain = Tzispa::Domain.new app
        @name = name
      end

      def generate
        Tzispa::Controller::Api.new.generate_handler(domain, name)
      end

    end

  end
end

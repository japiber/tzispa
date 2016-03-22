require 'tzispa/rig/template'

module Tzispa
  module CommandCli

    class Rig

      attr_reader :name, :domain, :type

      def initialize(name, app, type)
        @prj = Tzispa::CommandCli::Project.open
        raise "Application '#{app}' does not exists in project file" unless @prj.apps.include?(app)
        @domain = Tzispa::Domain.new app
        @type = type.to_sym
        @name = name
      end

      def create
        tpl = Tzispa::Rig::Template.new(name: name, type: type, domain: domain, format: :htm)
        tpl.create
      end


    end

  end
end

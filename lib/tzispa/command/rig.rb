require 'tzispa/rig/template'

module Tzispa
  module Command

    class Rig

      attr_reader :name, :domain, :type, :mime_format

      def initialize(name, app, type, mime_format = nil)
        @prj = Project.open
        raise "Application '#{app}' does not exists in project file" unless @prj.apps.include?(app)
        @domain = Tzispa::Domain.new app
        @type = type.to_sym
        @name = name
        @mime_format = mime_format
      end

      def generate
        Tzispa::Rig::Template.new(name: name, type: type, domain: domain, format: mime_format).create
      end

    end

  end
end

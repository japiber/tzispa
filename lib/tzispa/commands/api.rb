# frozen_string_literal: true

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
        generate_handler(domain, name, request_method)
      end

      private

      def generate_handler(domain, name, request_method)
        class_name = Tzispa::Api.handler_class_name(name)
        file_name = Tzispa::Api.handler_class_file(domain, name, request_method)
        raise "The handler '#{name}' already exist" if File.exist?(file_name)
        namespace = Tzispa::Api.handler_namespace(domain, request_method)
        File.open(file_name, 'w') do |f|
          f.puts handler_code(namespace, class_name)
        end
      end

      def handler_code(namespace, class_name)
        String.new.tap do |code|
          code.indenter("require 'tzispa/api/handler'\n\n")
          level = 0
          namespace.split('::').each do |ns|
            code.indenter("module #{ns}\n", level.positive? ? 2 : 0).to_s
            level += 1
          end
          code.indenter("\nclass #{class_name} < Tzispa::Api::Handler\n\n", 2)
          code.indenter("end\n\n")
          namespace.split('::').each { code.unindenter("end\n", 2) }
        end
      end
    end

  end
end

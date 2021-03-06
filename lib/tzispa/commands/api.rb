# frozen_string_literal: true

require 'fileutils'
require 'tzispa/engine/rig/api'
require 'tzispa/commands/command'
require 'tzispa_utils'

module Tzispa
  module Commands

    class Api < Command
      attr_reader :name, :domain, :verb

      def initialize(name, app, verb, options = nil)
        super(options)
        @domain = Tzispa::Domain.new app
        @name = name
        @verb = verb
      end

      def generate
        file_name = Tzispa::Engine::Rig::Api.handler_class_file(domain, name, verb)
        raise "The handler '#{name}' already exist" if File.exist?(file_name)
        namespace = Tzispa::Engine::Rig::Api.handler_namespace(domain, verb)
        class_name = Tzispa::Engine::Rig::Api.handler_class_name(name)
        create_file file_name, namespace, class_name
      end

      private

      def create_file(file_name, ns, class_name)
        dir, = Pathname.new(file_name).split
        FileUtils.mkpath dir
        File.open(file_name, 'w') do |f|
          f.puts handler_code(ns, class_name)
        end
      end

      def handler_code(namespace, class_name)
        Tzispa::Utils::Indenter.new.tap do |code|
          code << "require 'tzispa/rig/handler'\n\n"
          level = 0
          namespace.split('::').each do |ns|
            level.positive? ? code.indent << "module #{ns}\n" : code << "module #{ns}\n"
            level += 1
          end
          code.indent << "\nclass #{class_name} < Tzispa::Rig::Handler\n\n"
          code << "end\n\n"
          namespace.split('::').each { code.unindent << "end\n" }
        end.to_s
      end
    end

  end
end

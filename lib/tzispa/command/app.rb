require 'json'
require 'tzispa/domain'
require 'tzispa/utils/string'
require 'tzispa/config/appconfig'
require_relative 'project'

module Tzispa
  module Command

    class App

      APP_STRUCTURE = [
        'api',
        'config',
        'config/locales',
        'error',
        'rig',
        'rig/block',
        'rig/layout',
        'rig/static'
      ]

      attr_reader :domain, :config

      def initialize(name)
        @domain = Tzispa::Domain.new(name)
      end

      def generate(host, mount_path=nil)
        update_project
        create_structure
        create_class mount_path
        create_appconfig(host)
        create_home_layout
      end

      private

      def update_project
        prj = Project.open
        raise "Application '#{domain.name}' already exist in this project" if prj.apps.include?(domain.name)
        prj.apps << domain.name
        prj.close
      end

      def create_class(mount_path=nil)
        appclass = "#{TzString.camelize domain.name}App"
        mount_path ||= DEFAULT_MOUNT_PATH
        class_code = TzString.new
        File.open("#{Project::START_FILE}","a") do |f|
          f.puts class_code.indenter("\nclass #{appclass} < Tzispa::Application\n\n")
          f.puts class_code.indenter("def initialize", 2)
          f.puts class_code.indenter("super(:#{domain.name})", 2)
          f.puts class_code.unindenter("end\n\n", 2)
          f.puts class_code.unindenter("end\n\n", 2)
          f.puts class_code.indenter("#{appclass}.mount '/#{mount_path}', self do |route|")
          f.puts class_code.indenter("route.index '/', [:get, :head]", 2)
          f.puts class_code.indenter("route.api   '/__api_:sign/:handler/:verb(~:predicate)(/:sufix)', [:get, :head, :post]")
          f.puts class_code.indenter("route.site  '/:title(/@:id0)(@:id1)(@~:id2)(@@:id3)(@@~:id4)(@@@:id5)/:layout.:format', [:get, :head]")
          f.puts class_code.unindenter("end\n\n", 2)
        end
      end

      def create_structure
        unless File.exist? domain.path
          Dir.mkdir "#{domain.path}"
          APP_STRUCTURE.each { |appdir|
            Dir.mkdir "#{domain.path}/#{appdir}"
          }
        end
      end

      def create_appconfig(host)
        appconfig = Tzispa::Config::AppConfig.new(domain)
        @config = appconfig.create_default host: host
      end

      def create_home_layout
        tpl = Tzispa::Rig::Template.new(name: config&.default_layout || 'index', type: :layout, domain: domain, format: :htm)
        tpl.create("<html><body><h1>Welcome: Tzispa #{domain.name} application is working!</h1></body></html>")
      end

    end

  end
end

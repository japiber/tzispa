require 'json'
require 'tzispa/domain'
require 'tzispa/utils/string'
require 'tzispa/utils/indenter'
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
        mount_path ||= DEFAULT_MOUNT_PATH
        File.open("#{Project::START_FILE}","a") do |f|
          f.puts new_app_code(mount_path)
        end
      end

      def new_app_code(mount_path)
        appclass = "#{TzString.camelize domain.name}App"
        Tzispa::Utils::Indenter.new(2).tap { |code|
          code << "\nclass #{appclass} < Tzispa::Application\n\n"
          code.indent << "def initialize\n"
          code.indent << "super(:#{domain.name})\n"
          code.unindent << "end\n\n"
          code.unindent << "end\n\n"
          code << "#{appclass}.mount '/#{mount_path}', self do |route|\n"
          code.indent << "route.index '/', [:get, :head]\n"
          code << "route.api   '/__api_:sign/:handler/:verb(~:predicate)(/:sufix)', [:get, :head, :post]\n"
          code << "route.site  '/:title(/@:id0)(@:id1)(@~:id2)(@@:id3)(@@~:id4)(@@@:id5)/:layout.:format', [:get, :head]\n"
          code.unindent << "end\n\n"
        }.to_s
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

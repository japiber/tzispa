require 'json'
require 'tzispa/domain'
require 'tzispa/utils/string'
require 'tzispa/utils/indenter'
require 'tzispa/config/appconfig'
require_relative 'project'

module Tzispa
  module Command

    class App

      using Tzispa::Utils

      APP_STRUCTURE = [
        'api',
        'locales',
        'error',
        'helpers',
        'middleware',
        'rig',
        'rig/block',
        'rig/layout',
        'rig/static',
        'services'
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

      def app_class_name
        @app_class_name ||= "#{domain.name.camelize}App"
      end

      def update_project
        prj = Project.open
        raise "Application '#{domain.name}' already exist in this project" if prj.apps.include?(domain.name)
        prj.apps << domain.name
        prj.close
      end

      def create_class(mount_path=nil)
        mount_path ||= DEFAULT_MOUNT_PATH
        File.open("#{Project::START_FILE}","a") do |f|
          f.puts write_app_code(mount_path)
        end
      end

      def write_app_code(mount_path)
        mount_path = "/#{mount_path}" unless mount_path.start_with? '/'
        Tzispa::Utils::Indenter.new(2).tap { |code|
          code << "(Class.new Tzispa::Application).run :#{domain.name}, builder: self#{", on: \'"+mount_path+"\'" if mount_path && mount_path.length > 0}  do\n\n"
          code.indent << "route_rig_signed_api  '/api_:sign/:handler/:verb(~:predicate)(/:sufix)'\n"
          code        << "route_rig_api         '/api/:handler/:verb(~:predicate)(/:sufix)'\n"
          code        << "route_rig_index       '/'\n\n"
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

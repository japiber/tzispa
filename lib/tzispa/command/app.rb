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
        'helpers',
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
        @app_class_name ||= "#{TzString.camelize domain.name}App"
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
          f.puts new_app_code(mount_path)
        end
      end

      def new_app_code(mount_path)
        Tzispa::Utils::Indenter.new(2).tap { |code|
          code << "\nclass #{app_class_name} < Tzispa::Application; end\n\n"
          code << "my_app = #{app_class_name}.new(#{domain.name}, on: '#{mount_path}')  do\n\n"
          code.indent << "route_rig_signed_api  '/__api_:sign/:handler/:verb(~:predicate)(/:sufix)'"
          code.indent << "route_rig_api         '/api/:handler/:verb(~:predicate)(/:sufix)'"
          code.indent << "route_rig_index       '/'"
          code.unindent << "end\n\n"
          code << "my_app.run self"
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

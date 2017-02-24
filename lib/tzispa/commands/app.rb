require 'json'
require 'tzispa/domain'
require 'tzispa/utils/string'
require 'tzispa/utils/indenter'
require 'tzispa/config/appconfig'
require_relative 'command'
require_relative 'project'

module Tzispa
  module Commands
    class App
      using Tzispa::Utils

      APP_STRUCTURE = [
        'api', 'locales', 'error', 'helpers', 'view', 'view/_',
        'view/_/block', 'view/_/layout', 'view/_/static', 'services'
      ]

      attr_reader :domain

      def initialize(name)
        @domain = Tzispa::Domain.new(name)
      end

      def generate(mount_path, index_layout, locale)
        raise 'You must be located in a Tzispa project folder to generate new apps' unless project_folder?
        update_rackup mount_path
        create_structure
        create_appconfig index_layout, locale
        create_home_layout
        create_routes
      end

      private

      def project_folder?
        File.exist?(Tzispa::Environment::DEFAULT_RACKUP)
      end

      def update_rackup(mount_path=nil)
        mount_path ||= DEFAULT_MOUNT_PATH
        File.open(Tzispa::Environment::DEFAULT_RACKUP, 'a') do |f|
          f.puts write_app_code(mount_path)
        end
      end

      def write_app_code(mount_path)
        map_path = mount_path.start_with?('/') ? mount_path : "/#{mount_path}"
        Tzispa::Utils::Indenter.new(2).tap { |code|
          code << "\nmap '#{map_path}' do\n"
          code.indent << "run Tzispa::Application.new(:#{domain.name},on: '#{map_path}').load!\n"
          code.unindent << "end\n"
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

      def create_appconfig(default_layout, locale)
        appconfig = Tzispa::Config::AppConfig.new(domain)
        @config = appconfig.create_default(default_layout, locale)
      end

      def create_home_layout
        tpl = Tzispa::Rig::Template.new(name: @config.default_layout || 'index', type: :layout, domain: domain, content_type: :htm)
        tpl.create("<html><body><h1>Welcome: Tzispa #{domain.name} application is working!</h1></body></html>")
      end

      def create_routes
        File.open("config/routes/#{domain.name}.rb", 'w') do |file|
          file.puts '# app routes definitions \n'
          file.puts "index       '/', controller: 'layout:render!'"
          file.puts "signed_api  '/klapi_:sign/:handler/:verb(~:predicate)(/:sufix)'"
          file.puts "api         '/klapi/:handler/:verb(~:predicate)(/:sufix)'"
        end
      end

    end
  end
end

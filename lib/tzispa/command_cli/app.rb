require 'json'
require_relative 'project.rb'
require 'tzispa/domain'
require 'tzispa/utils/string'
require 'tzispa/config/appconfig'

module Tzispa
  module CommandCli

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

      attr_reader :domain

      def initialize(name)
        @domain = Tzispa::Domain.new(name)
      end

      def create(host, mount_path=nil)
        update_project
        create_class mount_path
        create_structure
        create_appconfig(host)
      end

      private

      def update_project
        prj = Tzispa::CommandCli::Project.open
        raise "Application '#{domain.name}' already exist in this project" if prj.apps.include?(domain.name)
        prj.apps << domain.name
        prj.close
      end

      def create_class(mount_path=nil)
        appclass = "#{TzString.camelize domain.name}App"
        mount_path ||= DEFAULT_MOUNT_PATH
        File.open("#{Tzispa::CommandCli::Project::START_FILE}","a") do |f|
          f.puts "\nclass #{appclass} < Tzispa::Application"
          f.puts "  def initialize"
          f.puts "    super(:#{domain.name})"
          f.puts "  end"
          f.puts "end\n"
          f.puts "#{appclass}.mount '#{mount_path}', self do |route|"
          f.puts "  route.index '/', [:get, :head]"
          f.puts "  route.api   '/__api_:sign/:handler/:verb(~:predicate)(/:sufix)', [:get, :head, :post]"
          f.puts "  route.site  '/:title(/@:id0)(@:id1)(@~:id2)(@@:id3)(@@~:id4)(@@@:id5)/:layout.:format', [:get, :head]"
          f.puts "end\n\n"
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
        appconfig.create_default host: host
      end

    end

  end
end

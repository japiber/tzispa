require 'json'
require "base64"
require "zlib"
require 'pathname'
require "tzispa/tzisparc"
require "tzispa/environment"
require 'tzispa/helpers/security'
require "tzispa/commands/helpers/project"
require "tzispa/commands/helpers/i18n"

module Tzispa
  module Commands

    class Project
      include Tzispa::Helpers::Security
      include Tzispa::Commands::Helpers::Project
      include Tzispa::Commands::Helpers::I18n

      attr_accessor :name, :apps, :created

      def initialize(name)
        @name = name
        @apps = Array.new
      end

      def generate
        if generate_structure
          generate_projectrc
          generate_environment
          generate_rackup
          generate_pumaconfig
          generate_gitignore
          generate_i18n 'en'
          generate_i18n 'es'
        end
      end

      private

      def generate_structure
        unless File.exist? name
          Dir.mkdir "#{name}"
          PROJECT_STRUCTURE.each { |psdir|
            Dir.mkdir "#{name}/#{psdir}"
            File.open("#{name}/#{psdir}/.gitkeep", 'w')
          }
        end
      end

      def generate_projectrc
        rc = Tzisparc.new Pathname.new(Dir.pwd).join(name)
        rc.generate name
      end

      def generate_environment
        File.open("#{name}/.env.production", 'w') { |file| file.puts ENVC_DEFAULTS % secret(64) }
        File.open("#{name}/.env.development", 'w') { |file| file.puts ENVC_DEFAULTS % secret(64) }
        File.open("#{name}/.env.test", 'w') { |file| file.puts ENVC_DEFAULTS % secret(64) }
      end

      def generate_rackup
        File.open("#{name}/#{Tzispa::Environment::DEFAULT_RACKUP}", 'w') do |file|
          file.puts "\# project #{name} started on #{Time.now}"
          file.puts "require_relative 'config/boot'\n"
          file.puts "run Tzispa::Application.new(:#{name}).load!"
        end
      end

      def generate_gitignore
        File.open("#{name}/.gitignore","w") do |file|
          GIT_IGNORE.each { |sig| file.puts sig }
        end
      end

      def generate_pumaconfig
        File.open("#{name}/config/#{PUMA_CONFIG_FILE}", "w") do |f|
          f.puts PUMA_CONFIG
        end
      end

      def generate_boot
        File.open("#{name}/config/#{BOOT_FILE}", "w") do |file|
          file.puts "Tzispa::Environment['BUNDLE_GEMFILE'] ||= File.expand_path('../Gemfile', __dir__)"
          file.puts
          file.puts "require 'bundler/setup' # Set up gems listed in the Gemfile"
          file.puts
          file.puts "Bundler.require(*Tzispa::Environment.instance.bundler_groups)"
        end
      end

      def generate_i18n(lang)
        File.open("#{name}/config/locales/#{lang}.yml", "w") do |f|
          f.puts Zlib::Inflate.inflate(Base64.decode64(self.class.const_get("I18N_DEFAULTS_#{lang.upcase}"))).force_encoding('UTF-8').encode
        end
      end

    end
  end
end
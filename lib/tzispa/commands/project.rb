# frozen_string_literal: true

require 'json'
require 'base64'
require 'zlib'
require 'pathname'
require 'tzispa/tzisparc'
require 'tzispa/environment'
require 'tzispa/helpers/security'
require 'tzispa/commands/helpers/project'
require 'tzispa/commands/helpers/i18n'
require 'tzispa/config/db_config'

module Tzispa
  module Commands

    class Project
      include Tzispa::Helpers::Security
      include Tzispa::Commands::Helpers::Project
      include Tzispa::Commands::Helpers::I18n

      attr_accessor :name, :apps, :created

      def initialize(name)
        @name = name
        @apps = []
      end

      def generate
        return unless generate_structure
        generate_projectrc
        generate_environment
        generate_rackup
        generate_gemfile
        generate_puma_config
        generate_boot_config
        generate_gitignore
        generate_i18n(%w[en es])
        generate_database_config
      end

      private

      def generate_structure
        return if File.exist? name
        Dir.mkdir name.to_s
        PROJECT_STRUCTURE.each do |psdir|
          Dir.mkdir "#{name}/#{psdir}"
          File.open("#{name}/#{psdir}/.gitkeep", 'w')
        end
      end

      def generate_projectrc
        rc = Tzisparc.new Pathname.new(Dir.pwd).join(name)
        rc.generate
      end

      def generate_environment
        File.open("#{name}/.env.production", 'w') { |file| file.puts ENVC_DEFAULTS % secret(64) }
        File.open("#{name}/.env.deployment", 'w') { |file| file.puts ENVC_DEFAULTS % secret(64) }
        File.open("#{name}/.env.test", 'w') { |file| file.puts ENVC_DEFAULTS % secret(64) }
      end

      def generate_rackup
        File.open("#{name}/#{Tzispa::Environment::DEFAULT_RACKUP}", 'w') do |file|
          file.puts "\# project #{name} started on #{Time.now}"
        end
      end

      def generate_gitignore
        File.open("#{name}/.gitignore", 'w') do |file|
          GIT_IGNORE.each { |sig| file.puts sig }
        end
      end

      def generate_gemfile
        File.open("#{name}/#{GEMFILE}", 'w') do |file|
          file.puts GEMFILE_CONTENT
        end
      end

      def generate_puma_config
        File.open("#{name}/config/#{PUMA_CONFIG_FILE}", 'w') do |f|
          f.puts PUMA_CONFIG % name
        end
      end

      def generate_boot_config
        File.open("#{name}/config/#{BOOT_CONFIG_FILE}", 'w') do |f|
          f.puts BOOT_CONFIG
        end
      end

      def generate_database_config
        Tzispa::Config::DbConfig.create_default name
      end

      def generate_boot
        File.open("#{name}/config/#{BOOT_FILE}", 'w') do |file|
          file.puts 'require \'bundler/setup\' # Set up gems listed in the Gemfile'
          file.puts
          file.puts 'Bundler.require(*Tzispa::Environment.instance.bundler_groups)'
        end
      end

      def generate_i18n(langs)
        langs.each do |lang|
          File.open("#{name}/config/locales/#{lang}.yml", 'w') do |f|
            content = Base64.decode64(self.class.const_get("I18N_DEFAULTS_#{lang.upcase}"))
            content = Zlib::Inflate.inflate(content)
            f.puts content.force_encoding('UTF-8').encode
          end
        end
      end
    end

  end
end

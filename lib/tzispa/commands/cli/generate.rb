# frozen_string_literal: true

require 'thor'

module Tzispa
  module Commands
    module Cli

      class Generate < Thor
        require 'tzispa/commands/app'
        desc 'app', 'Generate new application into a project'
        method_option :mount, aliases: '-m', desc: 'The mount point for this app', default: '/'
        method_option :index, aliases: '-i', desc: 'Default index layout', default: 'index'
        method_option :locale, aliases: '-l', desc: 'Default app locale', default: 'en'
        def app(name)
          tzapp = Tzispa::Commands::App.new(name)
          tzapp.generate(options[:mount], options[:index], options[:locale])
          puts "App '#{name}' has been created"
        end

        require 'tzispa/commands/rig'
        desc 'rig', 'Generate new rig template'
        method_option :app, aliases: '-a',
                            desc: 'The app where create the new template', required: true
        method_option :type, aliases: '-t',
                             desc: 'Template type: block, static or layout', required: true
        def rig(name)
          tpl = Tzispa::Commands::Rig.new(name, options[:app], options[:type])
          tpl.generate
          puts "Rig #{options[:type]} template '#{name}' has been created in #{options[:app]}"
        end

        require 'tzispa/commands/repository'
        desc 'repository', 'Generate new repsitory'
        method_option :adapter, aliases: '-a',
                                desc: 'Database adapter to use in the repository', required: true
        method_option :database, aliases: '-d',
                                 desc: 'Database connection string or path', required: true
        def repository(name)
          repo = Tzispa::Commands::Repository.new name, options[:adapter], options[:database]
          repo.generate
          puts "Repository #{name} has been created into local project"
        end

        require 'tzispa/commands/api'
        desc 'api', 'Generate new api handler'
        method_option :app, aliases: '-a',
                            desc: 'The app where the api handler will be created', required: true
        def api(name)
          hnd = Tzispa::Commands::Api.new(name, options[:app])
          hnd.generate
          puts "Api handler '#{name}' has been created in #{options[:app]}"
        end
      end

    end
  end
end

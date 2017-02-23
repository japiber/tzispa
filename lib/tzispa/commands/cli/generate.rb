require 'thor'


module Tzispa
  module Commands
    module Cli

      class Generate < Thor

        require 'tzispa/commands/project'
        desc 'project', 'Generate a new Tzispa project'
        def project(name)
          require 'tzispa/commands/project'
          Tzispa::Commands::Project.new(name).generate
          puts "Project '#{name}' has been created"
        end

        require 'tzispa/commands/app'
        desc 'app', 'Generate new application into a project'
        method_option :mount, :aliases => "-m", :desc => "The mount point for this app", :default => ""
        method_option :host, :aliases => "-h", :desc => "The hostname used for this app ", :required => true
        def app(name)
          require 'tzispa/commands/app'
          tzapp = Tzispa::Commands::App.new(name)
          tzapp.generate(options[:host], options[:mount])
          puts "App '#{name}' has been created"
        end

        require 'tzispa/commands/rig'
        desc 'rig', 'Generate new rig template'
        method_option :app, :aliases => "-a", :desc => "The app where the new template will be created", :required => true
        method_option :type, :aliases => "-t", :desc => "The template type: block, static or layout ", :required => true
        def rig(name)
          require 'tzispa/commands/rig'
          tpl = Tzispa::Commands::Rig.new(name, options[:app], options[:type])
          tpl.generate
          puts "Rig #{options[:type]} template '#{name}' has been created in #{options[:app]}"
        end

        require 'tzispa/commands/api'
        desc 'api', 'Generate new api handler'
        method_option :app, :aliases => "-a", :desc => "The app where the api handler will be created", :required => true
        def api(name)
          require 'tzispa/commands/api'
          hnd = Tzispa::Commands::Api.new(name, options[:app])
          hnd.generate
          puts "Api handler '#{name}' has been created in #{options[:app]}"
        end


      end

    end
  end
end
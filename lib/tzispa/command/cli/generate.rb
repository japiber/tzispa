require 'thor'
require 'tzispa/command/project'
require 'tzispa/command/app'
require 'tzispa/command/rig'

module Tzispa
  module Command
    module Cli

      class Generate < Thor

        desc 'project', 'Generate Tzispa project components'
        def project(name)
          Tzispa::Command::Project.new(name).generate
          puts "Project '#{name}' has been created"
        end

        desc 'app', 'Generate new application into a project'
        method_option :mount, :aliases => "-m", :desc => "The mount point for this app", :default => ""
        method_option :host, :aliases => "-h", :desc => "The hostname used for this app ", :required => true
        def app(name)
          tzapp = Tzispa::Command::App.new(name)
          tzapp.generate(options[:host], options[:mount])
          puts "App '#{name}' has been created"
        end


        desc 'rig', 'Generate new rig template'
        method_option :app, :aliases => "-a", :desc => "The app where the new template will be created", :required => true
        method_option :type, :aliases => "-t", :desc => "The template type: block, static or layout ", :required => true
        def rig(name)
          tpl = Tzispa::Command::Rig.new(name, options[:app], options[:type])
          tpl.generate
          puts "Rig #{options[:type]} template '#{name}' has been created in #{options[:app]}"
        end

      end

    end
  end
end

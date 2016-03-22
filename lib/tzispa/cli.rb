require 'thor'
require 'tzispa/command_cli/project'
require 'tzispa/command_cli/app'
require 'tzispa/command_cli/rig'

module Tzispa

  class Cli < Thor

    desc 'version', 'Prints Tzispa version'
    def version
      require 'tzispa/version'
      puts "v#{VERSION}"
    end

    desc 'project', 'Generate Tzispa project components'
    def project(name)
      CommandCli::Project.new(name).create
      puts "created new project #{name}"
    end

    desc 'app', 'Generate new application into a project'
    method_option :mount, :aliases => "-m", :desc => "The mount point for this app", :required => true
    method_option :host, :aliases => "-h", :desc => "The hostname used for this app ", :required => true
    def app(name)
      CommandCli::App.new(name).create(options[:host], options[:mount])
      puts "created new app #{name}"
    end

    desc 'rig', 'Generate new rig template'
    method_option :app, :aliases => "-a", :desc => "The app where the new template will be created", :required => true
    method_option :type, :aliases => "-t", :desc => "The template type: block, static or layout ", :required => true
    def rig(name)
      CommandCli::Rig.new(name, options[:app], options[:type]).create
      puts "created new #{options[:type]} rig '#{name}' in #{options[:app]}"
    end


  end

end

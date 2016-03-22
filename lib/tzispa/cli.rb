require 'thor'
require 'tzispa/command_cli/project'
require 'tzispa/command_cli/app'

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

  end

end

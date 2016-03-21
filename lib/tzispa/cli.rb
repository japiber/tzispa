require 'thor'
require 'tzispa/cli/project'

module Tzispa

  class Cli < Thor

    desc 'version', 'Prints Tzispa version'
    def version
      require 'tzispa/version'
      puts "v#{Tzispa::VERSION}"
    end

    desc 'project', 'Generate Tzispa project components'
    def project(name)
      Tzispa::CommandCli::Project.new.create(name)
      puts "created new project #{name}"
    end

    desc 'app', 'Generate new application into a project'
    method_option :domain, :aliases => "-d", :desc => "The app domain name", :required => true
    method_option :mount, :aliases => "-m", :desc => "The mount point for this app", :required => true
    method_option :host, :aliases => "-h", :desc => "The hostname used for this app ", :required => true
    def app(name)
      Tzispa::CommandCli::App.new.create name, options[:domain], options[:mount]
      puts "created new app #{name}"
    end

  end

end

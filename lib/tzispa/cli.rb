require 'thor'

module Tzispa

  class Cli < Thor

    desc 'version', 'Prints Tzispa version'
    def version
      require 'tzispa/version'
      puts "v#{Tzispa::VERSION}"
    end

    desc 'new', 'Generate Tzispa project components'
    method_option :domain, :aliases => "-d", :desc => "The app domain name", :required => true
    method_option :mount, :aliases => "-m", :desc => "The mount point for this app", :required => true
    method_option :host, :aliases => "-h", :desc => "The hostname used for this app ", :required => true
    def new(name)
      puts "creating new #{name}"
    end

  end

end

require 'thor'

module Tzispa

  class Cli < Thor

    desc 'version', 'Prints Tzispa version'
    def version
      require 'tzispa/version'
      puts "v#{Tzispa::VERSION}"
    end

    desc 'version', 'Generate Tzispa project related items'
    def new(name)
      puts "creating new #{name}"
    end

  end

end

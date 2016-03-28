require 'thor'

module Tzispa

  class Cli < Thor

    desc 'version', 'Prints Tzispa version'
    def version
      require 'tzispa/version'
      puts "v#{VERSION}"
    end

    require 'tzispa/command/cli/generate'
    register Tzispa::Command::Cli::Generate, 'generate', 'generate [SUBCOMMAND]', 'Generate Tzispa components'

  end

end

require 'thor'
require 'tzispa'

module Tzispa

  class Cli < Thor

    desc 'version', 'Prints Tzispa version'
    def version
      require 'tzispa/version'
      puts "v#{VERSION}"
    end

    require 'tzispa/commands/server'
    desc 'server', 'Start Tzispa app server'
    method_option :port, aliases: '-p', desc: 'The port to run the server on'
    method_option :server, desc: 'Choose a specific Rack::Handler (webrick, thin, etc)'
    method_option :rackup, desc: 'A rackup configuration file path to load (config.ru)'
    method_option :host, desc: 'The host address to bind to'
    method_option :debug, desc: 'Turn on debug output'
    method_option :warn, desc: 'Turn on warnings'
    method_option :daemonize, desc: 'If true, the server will daemonize itself'
    method_option :help, desc: 'Displays the help usage'
    def server
      if options[:help]
        invoke :help, ['server']
      else
        Tzispa::Commands::Server.new(options).start
      end
    end

    require 'tzispa/commands/console'
    desc 'console', 'Starts a Tzispa console'
    method_option :engine, desc: "Choose a specific console engine: (#{Tzispa::Commands::Console::ENGINES.keys.join('/')})"
    method_option :help, desc: 'Displays the usage help'
    def console
      if options[:help]
        invoke :help, ['console']
      else
        Tzispa::Commands::Console.new(options).start
      end
    end

    require 'tzispa/commands/cli/generate'
    register Tzispa::Commands::Cli::Generate, 'generate', 'generate [SUBCOMMAND]', 'Generate Tzispa projects and components'

  end

end

require 'forwardable'

module Tzispa

  # Thie class defines a environment to hold application state in runtime
  class Context
    extend Forwardable

    attr_reader    :app, :env, :repository
    def_delegators :@app, :config, :logger, :domain

    def initialize(environment)
      @env = environment
      @app = environment[:tzispa__app]
      @repository = @app.repository.dup if @app.repository
    end

  end

end

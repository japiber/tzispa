# frozen_string_literal: true

require 'dotenv'

module Tzispa

  class Env
    def initialize(env: ENV)
      @env = env
    end

    def [](key)
      @env[key]
    end

    def []=(key, value)
      @env[key] = value
    end

    def key?(key)
      @env.key? key
    end

    def load!(path)
      return unless defined?(Dotenv)

      contents = ::File.open(path, 'rb:bom|utf-8', &:read)
      parsed   = Dotenv::Parser.call(contents)

      parsed.each do |k, v|
        next if @env.key?(k)
        @env[k] = v
      end
      nil
    end
  end

end

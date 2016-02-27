# frozen_string_literal: true

module Tzispa
  class Domain

    attr_reader :name, :root

    DEFAULT_DOMAIN_NAME   = :default
    DEFAULT_DOMAINS_ROOT  = :domains


    def initialize(name: DEFAULT_DOMAIN_NAME, root: DEFAULT_DOMAINS_ROOT)
      @name = name || DEFAULT_DOMAIN_NAME
      @root = root || DEFAULT_DOMAINS_ROOT
    end

    def path
      "#{root.to_s.downcase}/#{name.to_s.downcase}".freeze
    end

    def require(file)
      Kernel.require "./#{path}/#{file}"
    end

    def load(file)
      Kernel.load "./#{path}/#{file}.rb"
    end

    def self.require(domain, file)
      self.new(name: domain).require(file)
    end

    def self.load(domain, file)
      self.new(name: domain).load(file)
    end


  end
end

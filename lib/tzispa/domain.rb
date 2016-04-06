# frozen_string_literal: true

module Tzispa
  class Domain

    attr_reader :name, :root

    DEFAULT_DOMAIN_NAME   = :default
    DEFAULT_DOMAINS_ROOT  = :apps


    def initialize(name=DEFAULT_DOMAIN_NAME, root=DEFAULT_DOMAINS_ROOT)
      @name = name
      @root = root
    end

    def path
      "#{root.to_s.downcase}/#{name.to_s.downcase}".freeze
    end

    def require(file)
      Kernel.require "./#{path}/#{file}"
    end

    def require_dir(dir)
      Dir["./#{path}/#{dir}/*.rb"].each { |file|
        name = file.split('/').last.split('.').first
        Kernel.require "./#{path}/#{dir}/#{name}"
      }
    end

    def load(file)
      Kernel.load "./#{path}/#{file}.rb"
    end

    def load_dir(dir)
      Dir["./#{path}/#{dir}/*.rb"].each { |file|
        name = file.split('/').last
        Kernel.load "./#{path}/#{dir}/#{name}"
      }
    end

    def self.require(domain, file)
      self.new(name: domain).require(file)
    end

    def self.load(domain, file)
      self.new(name: domain).load(file)
    end


  end
end

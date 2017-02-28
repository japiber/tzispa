# frozen_string_literal: true

require 'tzispa/utils/string'

module Tzispa

  class Domain
    using Tzispa::Utils

    attr_reader :name

    def initialize(name)
      @name = name
      @root = "#{Tzispa::Environment.instance.root}/#{Tzispa::Environment.instance.apps_path}"
      instance_eval "module ::#{name.to_s.capitalize}; end"
    end

    def path
      @path ||= root % name.to_s.downcase
    end

    def require(file)
      Kernel.require "#{path}/#{file}"
    end

    def load(file)
      Kernel.load "#{path}/#{file}.rb"
    end

    def require_dir(dir = nil)
      rqpath = dir ? "#{path}/#{dir}" : path.to_s
      Dir["#{rqpath}/*.rb"].each do |file|
        name = file.split('/').last.split('.').first
        Kernel.require "#{rqpath}/#{name}"
      end
    end

    def load_dir(dir = nil)
      rqpath = dir ? "#{path}/#{dir}" : path.to_s
      Dir["#{rqpath}/*.rb"].each do |file|
        name = file.split('/').last
        Kernel.load "#{rqpath}/#{name}"
      end
    end

    def include(cmod)
      name.to_s.capitalize.constantize.include cmod
    end

    def self.require(domain, file)
      new(name: domain).require(file)
    end

    def self.load(domain, file)
      new(name: domain).load(file)
    end

    protected

    attr_reader :root
  end

end

require 'json'

module Tzispa
  module Cli

    class Project

      PROJECT_STRUCTURE = [
        "#{name}",
        "#{name}/apps",
        "#{name}/config",
        "#{name}/config/locales",
        "#{name}/data",
        "#{name}/data/session",
        "#{name}/logs",
        "#{name}/public",
        "#{name}/public/css",
        "#{name}/public/img",
        "#{name}/public/js",
        "#{name}/repository"
      ]

      MARKFILE  = '.tzispaprj'
      STARTFILE = 'start.ru'

      attr_reader :name

      def initialize(name)
        @name = name
      end

      def create
        if create_structure
          create_markfile
          create_startfile
        end
      end

      private

      def create_structure
        unless File.exists PROJECT_STRUCTURE[0]
          PROJECT_STRUCTURE.each { |dir|
            Dir.mkdir directory
          }
        end
      end

      def create_markfile
        tags = {project: name, created: Time.new }
        File.open("#{name}/#{MARKFILE}","w") do |f|
          f.write tags.to_json
        end
      end

      def create_startfile
        File.open("#{name}/#{STARTFILE}","w") do |f|
          f.puts "require 'rack'\nrequire 'tzispa'"
        end
      end


    end

  end
end

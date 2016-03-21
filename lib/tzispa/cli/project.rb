require 'json'

module Tzispa
  module CommandCli

    class Project

      PROJECT_STRUCTURE = [
        'apps',
        'config',
        'config/locales',
        'data',
        'data/session',
        'logs',
        'public',
        'public/css',
        'public/css/fonts',
        'public/css/less',
        'public/img',
        'public/js',
        'repository'
      ]

      MARKFILE  = '.tzispaprj'
      STARTFILE = 'start.ru'

      attr_reader :name

      def create(name)
        @name = name
        if create_structure
          create_markfile
          create_startfile
        end
      end

      def self.check?
        File.exist? "#{MARKFILE}"
      end

      private

      def base_dir
        name
      end

      def create_structure
        unless File.exist? base_dir
          Dir.mkdir "#{base_dir}"
          PROJECT_STRUCTURE.each { |psdir|
            Dir.mkdir "#{base_dir}/#{psdir}"
          }
        end
      end

      def create_markfile
        tags = {
          project: name,
          created: Time.new
        }
        File.open("#{base_dir}/#{MARKFILE}","w") do |f|
          f.write tags.to_json
        end
      end

      def create_startfile
        File.open("#{base_dir}/#{STARTFILE}","w") do |f|
          f.puts "require 'rack'\nrequire 'tzispa'"
        end
      end


    end

  end
end

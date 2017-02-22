require 'pathname'
require 'tzispa/utils/hash'

module Tzispa

  class Tzisparc
    using Tzispa::Utils

    FILE_NAME = '.tzisparc'.freeze

    DEFAULT_ARCHITECTURE = 'domains'.freeze

    APP_ARCHITECTURE = 'app'.freeze

    ARCHITECTURE_KEY = 'architecture'.freeze

    PROJECT_NAME = 'project'.freeze

    DEFAULT_TEST_SUITE = 'minitest'.freeze

    TEST_KEY = 'test'.freeze

    DEFAULT_TEMPLATE = 'rig'.freeze

    TEMPLATE_KEY = 'template'.freeze

    SEPARATOR = '='.freeze

    def initialize(root)
      @root = root
    end

    def options
      @options ||= default_options.merge(file_options).symbolize!
    end

    def default_options
      @default_options ||= {
                             ARCHITECTURE_KEY => DEFAULT_ARCHITECTURE,
                             PROJECT_NAME     => project_name,
                             TEST_KEY         => DEFAULT_TEST_SUITE,
                             TEMPLATE_KEY     => DEFAULT_TEMPLATE
                           }
    end

    def exists?
      path_file.exist?
    end

    def generate
      File.open(path_file, 'w') do |file|
        default_options.each { |k, v| file.puts("#{k}#{SEPARATOR}#{v}") }
      end
    end

    private

    def file_options
      exists? ? parse_file(path_file) : {}
    end

    def parse_file(path)
      Hash.new.tap do |hash|
        File.readlines(path).each do |line|
          key, value = line.split(SEPARATOR)
          hash[key] = value.strip
        end
      end
    end

    def path_file
      @root.join FILE_NAME
    end

    def project_name
      ::File.basename(@root)
    end
  end
end
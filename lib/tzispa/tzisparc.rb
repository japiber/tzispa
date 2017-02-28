# frozen_string_literal: true

require 'pathname'
require 'tzispa/utils/hash'

module Tzispa

  class Tzisparc
    using Tzispa::Utils

    FILE_NAME = '.tzisparc'

    DEFAULT_ARCHITECTURE = 'domains'

    APP_ARCHITECTURE = 'app'

    ARCHITECTURE_KEY = 'architecture'

    PROJECT_NAME = 'project'

    DEFAULT_TEST_SUITE = 'minitest'

    TEST_KEY = 'test'

    DEFAULT_TEMPLATE = 'rig'

    TEMPLATE_KEY = 'template'

    SEPARATOR = '='

    def initialize(root)
      @root = root
    end

    def options
      @options ||= default_options.merge(file_options).symbolize!
    end

    def default_options
      @default_options ||= { ARCHITECTURE_KEY => DEFAULT_ARCHITECTURE,
                             PROJECT_NAME     => project_name,
                             TEST_KEY         => DEFAULT_TEST_SUITE,
                             TEMPLATE_KEY     => DEFAULT_TEMPLATE }
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
      {}.tap do |hash|
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

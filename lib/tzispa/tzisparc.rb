# frozen_string_literal: true

require 'pathname'
require 'tzispa_utils'
require 'tzispa/config/rc'

module Tzispa

  class Tzisparc
    using Tzispa::Utils::TzHash

    include Tzispa::Config::Rc

    FILE_NAME = '.tzisparc'

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
                             TEST_KEY         => DEFAULT_TEST_SUITE }
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

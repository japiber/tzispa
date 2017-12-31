# frozen_string_literal: true

require 'tzispa/data/config'
require 'tzispa/commands/helpers/repository'

module Tzispa
  module Commands

    class Repository
      include Tzispa::Commands::Helpers::Repository

      attr_reader :name, :adapter, :database

      def initialize(name, adapter, dbconn)
        @name = name
        @adapter = adapter
        @database = dbconn
      end

      def generate
        return unless generate_structure
        Tzispa::Data::Config.add_repository(name, adapter, database)
        return unless (db = Sequel.connect "#{adapter}://#{database}")
        tables = db.tables
        generate_models tables
        generate_entities tables
      end

      def generate_structure
        return if File.exist? repo_root
        Dir.mkdir repo_root
        REPO_STRUCTURE.each do |psdir|
          Dir.mkdir "#{repo_root}/#{psdir}"
          File.open("#{repo_root}/#{psdir}/.gitkeep", 'w')
        end
      end

      def generate_models(tables)
        tables.each do |tc|
          model_src = format(MODEL_TEMPLATE, name.capitalize, tc.capitalize, tc)
          File.open(model_file(tc), 'w') { |f| f << model_src }
        end
      end

      def generate_entities(tables)
        tables.each do |tc|
          entity_src = format(ENTITY_TEMPLATE, name.capitalize, tc.capitalize)
          File.open(entity_file(tc), 'w') { |f| f << entity_src }
        end
      end

      def repo_root
        @repo_root ||= File.join('repository', name)
      end

      def model_file(name)
        "#{repo_root}/model/#{name}.rb"
      end

      def entity_file(name)
        "#{repo_root}/entity/#{name}.rb"
      end
    end

  end
end

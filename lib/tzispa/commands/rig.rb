# frozen_string_literal: true

require 'tzispa/rig/template'

module Tzispa
  module Commands

    class Rig < Command
      attr_reader :name, :domain, :type, :mime_format

      def initialize(name, app, type, options = nil)
        super(options)
        @domain = Tzispa::Domain.new app
        @type = type.to_sym
        @name = name
      end

      def generate
        Tzispa::Rig::Template.new(name: name,
                                  type: type,
                                  domain: domain,
                                  content_type: :htm).create
      end
    end

  end
end

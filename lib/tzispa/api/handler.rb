# frozen_string_literal: true

require 'forwardable'
require 'json'

module Tzispa
  module Api

    class ApiException < StandardError; end
    class UnknownHandlerVerb < ApiException
      def initialize(s, name)
        super("Unknown verb: '#{s}' called in api handler '#{name}'")
      end
    end

    class Handler
      extend Forwardable

      def_delegators :@context, :request, :response, :app

      attr_reader :context, :status, :response_verb, :data

      HANDLED_UNDEFINED         = nil
      HANDLED_OK                = 1
      HANDLED_MISSING_PARAMETER = 98
      HANDLED_ERROR             = 99
      HANDLED_RESULT            = 200

      HANDLED_MESSAGES = {
        HANDLED_OK                => 'La operación se ha realizado correctamente',
        HANDLED_MISSING_PARAMETER => 'Error: faltan parámetros para realizar la operación',
        HANDLED_ERROR             => 'Error indeterminado: la operación no se ha podido realizar'
      }

      def initialize(context)
        @context = context
      end

      def result(response_verb:, status: HANDLED_UNDEFINED, data: nil, detailed_error: nil)
        @status = status
        @response_verb = response_verb
        @data = data
        @detailed_error = detailed_error
      end

      def result_json(status=HANDLED_UNDEFINED, data=nil, detailed_error=nil)
        result response_verb: :json, status: status, data: data.to_json, detailed_error: detailed_error
      end

      def message
        if @status.nil?
          nil
        elsif @status >= HANDLED_OK && @status <= HANDLED_ERROR
          HANDLED_MESSAGES[@status]
        elsif @status > HANDLED_ERROR && @status < HANDLED_RESULT
          error_message @status
        elsif @status > HANDLED_RESULT
          result_messages @status
        else
          nil
        end
      end

      def send(verb, predicate=nil)
        raise UnknownHandlerVerb.new(verb, self.class.name) unless self.class.provides? verb
        # allow compound predicates
        args = predicate ? predicate.split(',') : nil
        __send__ verb, *args
      end

      def self.provides(*args)
        (@provides ||= Hash.new).tap { |prv|
          args&.each { |s|
            prv[s] = s
          }
        }
      end

      def self.provides?(verb)
        value = value.to_sym
        @provides&.include?(verb) && public_method_defined?(@provides[verb])
      end

      def self.mapping(source, dest)
        @provides ||= Hash.new
        @provides[source] = dest
      end



      private

      def result_messages(status)
        self.class::RESULT_MESSAGES[status] if (defined?( self.class::RESULT_MESSAGES ) && self.class::RESULT_MESSAGES.is_a?(Hash))
      end

      def error_message(status)
        "#{self.class::ERROR_MESSAGES[status]}#{': '+@detailed_error if @detailed_error}" if (defined?( self.class::ERROR_MESSAGES ) && self.class::ERROR_MESSAGES.is_a?(Hash))
      end


    end
  end
end

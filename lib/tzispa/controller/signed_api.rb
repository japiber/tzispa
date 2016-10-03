# frozen_string_literal: true
require 'tzispa/controller/api'
require 'tzispa/helpers/security'

module Tzispa
  module Controller
    class SignedApi < Api

      include Tzispa::Helpers::Security


      def dispatch!
        raise Error::InvalidSign.new unless sign?
        super        
      end

      private

      def sign?
        context.router_params[:sign] == sign_array([
           context.router_params[:handler],
           context.router_params[:verb],
           context.router_params[:predicate]
          ],
          context.app.config.salt)
      end

    end
  end
end

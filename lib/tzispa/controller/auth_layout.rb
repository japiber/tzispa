# frozen_string_literal: true

require 'tzispa_rig'
require 'tzispa/controller/base'
require 'tzispa/controller/exceptions'
require 'tzispa/helpers/response'
require 'tzispa_rig'

module Tzispa
  module Controller
    class AuthLayout < Base
      include Tzispa::Helpers::Response

      def render!
        if (layout_name == login_layout) || context.login
          rig = Tzispa::Rig::Engine.layout name: layout_name, domain: application.domain, content_type: context.router_params[:format] || config.default_format
          response.body << rig.render(context)
          content_type rig.content_type
        else
          context.redirect login_layout, true, response
        end
      end

      private

      def layout_name
        context.layout || config.default_layout
      end

      def login_layout
        config.login_layout
      end


    end
  end
end

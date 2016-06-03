# frozen_string_literal: true

require 'tzispa_rig'
require 'tzispa/controller/base'
require 'tzispa/controller/exceptions'
require 'tzispa/helpers/response'

module Tzispa
  module Controller
    class Layout < Base

      include Tzispa::Helpers::Response

      def render!
        layout_format = context.router_params[:format] || context.config.default_format
        rig = context.app.engine.layout(name: layout_name, format: layout_format.to_sym)
        response.body << rig.render(context)
        content_type layout_format
      end

      private

      def layout_name
        context.layout || config.default_layout
      end


    end
  end
end

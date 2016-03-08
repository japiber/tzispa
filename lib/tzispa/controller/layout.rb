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
        layout = if context.config.auth_required && !context.logged? && context.router_params[:layout]
                   context.config.default_layout
                 else
                   context.router_params[:layout] || context.config.default_layout
                 end
        layout_format = context.router_params[:format] || context.config.default_format
        context.layout = layout
        rig = context.app.engine.layout(name: layout, format: layout_format.to_sym)
        response.body << rig.render(context)
        content_type layout_format
        set_layout_headers
      end

      private

      def set_layout_headers
        headers = Hash.new
        if context.app.config.cache.layout.enabled
          headers['Cache-Control'] = context.app.config.cache.layout.control
          if context.app.config.cache.layout.expires
            headers['Expires'] = (Time.now + context.app.config.cache.layout.expires).utc.rfc2822
          end
        end
        response.headers.merge!(headers)
      end


    end
  end
end

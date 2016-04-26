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
        set_layout_headers
      end

      private

      def layout_name
        if config.auth_required && !context.logged? && context.layout
          config.default_layout
        else
          context.layout || config.default_layout
        end
      end


      def set_layout_headers
        headers = Hash.new
        if config.cache.layout.enabled
          headers['Cache-Control'] = config.cache.layout.control
          if config.cache.layout.expires
            headers['Expires'] = (Time.now + config.cache.layout.expires).utc.rfc2822
          end
        end
        response.headers.merge!(headers)
      end


    end
  end
end

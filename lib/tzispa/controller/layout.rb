require 'tzispa'
require 'tzispa/rig'
require 'tzispa/controller/base'
require 'tzispa/controller/exceptions'
require 'tzispa/helpers/response'

module Tzispa
  module Controller
    class Layout < Base

      include Tzispa::Helpers::Response

      def render!
        layout = context.router_params[:layout] || context.config.default_layout
        layout = context.config.default_layout if context.config.auth_required && !context.logged? && layout != context.config.default_layout
        layout_format = context.router_params[:format] || context.config.default_format
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

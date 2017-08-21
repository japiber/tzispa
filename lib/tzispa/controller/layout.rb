# frozen_string_literal: true

require 'tzispa_rig'
require 'tzispa/controller/http'
require 'tzispa/controller/exceptions'
require 'tzispa/helpers/response'
require 'tzispa/http/rig_context'

module Tzispa
  module Controller
    class Layout < Tzispa::Controller::Http
      include Tzispa::Helpers::Response

      def initialize(app)
        super app, :render!, Tzispa::Http::RigContext, true
      end

      def render!
        rig = Tzispa::Rig::Engine.layout name: layout_name,
                                         domain: application.domain,
                                         content_type: context.router_params[:format] || config.default_format
        response.body << rig.render(context)
        content_type rig.content_type
      end

      private

      def invoke
        super
      rescue Tzispa::Rig::NotFound => ex
        prepare_response(404, error: ex)
      end

      def layout_name
        context.layout || config.default_layout
      end
    end

  end
end

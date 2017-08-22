# frozen_string_literal: true

require 'tzispa_rig'
require 'tzispa/controller/http'
require 'tzispa/controller/exceptions'
require 'tzispa/helpers/response'
require 'tzispa/engine/rig/context'

module Tzispa
  module Engine
    module Rig

      class Layout < Tzispa::Controller::Http
        include Tzispa::Helpers::Response

        def initialize(app)
          super app, :render!, Tzispa::Engine::Rig::Context, true
        end

        def render!
          layout_template.tap do |rig|
            response.body << rig.render(context)
            content_type rig.content_type
          end
        end

        private

        def layout_template
          Tzispa::Rig::Factory.layout name: layout_name,
                                      domain: application.domain,
                                      content_type: context.router_params[:format] ||
                                                   config.default_format
        end

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
end

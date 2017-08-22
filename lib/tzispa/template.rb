# frozen_string_literal: true

require 'tzispa/template/rig/router'

module Tzispa
  module Template

    def template_rig_routes(app, map_path)
      Rig::Router.new(app, map_path).setup
    end

  end
end

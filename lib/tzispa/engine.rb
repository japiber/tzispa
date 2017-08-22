# frozen_string_literal: true

require 'tzispa/engine/rig/router'

module Tzispa
  module Engine

    def rig_routes(app, map_path)
      Rig::Router.new(app, map_path).setup
    end

  end
end

# frozen_string_literal: true

require 'tzispa/engine/rig/layout'
require 'tzispa_helpers'

module Tzispa
  module Engine
    module Rig

      class AuthLayout < Tzispa::Engine::Rig::Layout
        include Tzispa::Helpers::SessionAuth

        before :login_redirect
      end

    end
  end
end

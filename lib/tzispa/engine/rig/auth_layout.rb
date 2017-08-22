# frozen_string_literal: true

require 'tzispa/engine/rig/layout'
require 'tzispa/helpers/login'

module Tzispa
  module Engine
    module Rig

      class AuthLayout < Tzispa::Engine::Rig::Layout
        include Tzispa::Helpers::Login

        before :login_redirect
      end

    end
  end
end

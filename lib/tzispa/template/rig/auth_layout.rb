# frozen_string_literal: true

require 'tzispa/template/rig/layout'
require 'tzispa/helpers/login'

module Tzispa
  module Template
    module Rig


      class AuthLayout < Tzispa::Template::Rig::Layout
        include Tzispa::Helpers::Login

        before :login_redirect
      end

    end
  end
end

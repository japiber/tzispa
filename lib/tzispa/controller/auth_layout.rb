# frozen_string_literal: true

require 'tzispa/controller/layout'
require 'tzispa/helpers/login'

module Tzispa
  module Controller

    class AuthLayout < Layout
      include Tzispa::Helpers::Login

      before :login_redirect
    end

  end
end

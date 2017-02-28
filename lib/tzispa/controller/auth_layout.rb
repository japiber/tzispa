# frozen_string_literal: true

require 'tzispa/controller/layout'

module Tzispa
  module Controller

    class AuthLayout < Layout
      before :login_redirect
    end

  end
end

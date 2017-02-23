# frozen_string_literal: true

require 'forwardable'
require 'tzispa/controller/layout'

module Tzispa
  module Controller
    class AuthLayout < Layout

      def_delegators :context, :login_redirect

      before :login_redirect


    end
  end
end

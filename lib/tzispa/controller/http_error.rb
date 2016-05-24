# frozen_string_literal: true

require 'tzispa/controller/base'
require 'tzispa/helpers/response'

module Tzispa
  module Controller

    class HttpError < Base

      include Tzispa::Helpers::Response

      def error_404
        not_found
      end


    end

  end
end

# frozen_string_literal: true

require 'tzispa/engine/rig/layout'
require 'tzispa_helpers'

module Tzispa
  module Engine
    module Rig
      module Auth

        class BasicLayout < Tzispa::Engine::Rig::Layout
          before :do_auth

          def do_auth
            # if settings.environment == :production
            #  unless (@env['HTTP_X_FORWARDED_PROTO'] || @env['rack.url_scheme']) == 'https'
            #    redirect "https://#{request.env['HTTP_HOST']}#{request.env['REQUEST_PATH']}"
            #  end
            # end
            protected!
          end

          private

          def protected!
            return if authorized?
            response['WWW-Authenticate'] = %(Basic realm="Testing HTTP Auth")
            throw(:halt, [401, 'Not authorized'])
          end

          def auth
            @auth ||= Rack::Auth::Basic::Request.new(request.env)
          end

          def authorized?
            auth.provided? &&
              auth.basic? &&
              auth.credentials &&
              auth.credentials == allowed_authorization
          end

          def allowed_authorization
            @allowed_authorization ||= [config.auth.basic.user, config.auth.basic.password].freeze
          end
        end

      end
    end
  end
end

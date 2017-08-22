# frozen_string_literal: true

require 'tzispa/http/context'
require 'tzispa/helpers/security'

module Tzispa
  module Template
    module Rig

      class Context < Tzispa::Http::Context
        include Tzispa::Helpers::Security

        def layout
          router_params&.fetch(:layout, nil)
        end

        def default_layout?(layout)
          config.default_layout&.to_sym == layout
        end

        def layout_path(layout, params = {})
          is_default = default_layout? layout
          params = normalize_format(params.merge(layout: layout)) unless is_default
          app.routes.path layout, params
        end

        def app_layout_path(app_name, layout, params = {})
          is_default = app[app_name].default_layout? == layout
          params = normalize_format(params.merge(layout: layout)) unless is_default
          app[app_name].routes.path layout, params
        end

        def layout_canonical_url(layout, params = {})
          "#{canonical_root}#{layout_path(layout, params)}"
        end

        def app_layout_canonical_url(app_name, layout, params = {})
          "#{canonical_root}#{app_layout_path(app_name, layout, params)}"
        end

        def path_sign?(sign, *args)
          sign == sign_array(args, config.salt)
        end

        def api(handler, verb, predicate = nil, sufix = nil, app_name = nil)
          if app_name
            app_canonical_url app_name, :api, handler: handler, verb: verb,
                                              predicate: predicate, sufix: sufix
          else
            canonical_url :api, handler: handler, verb: verb,
                                predicate: predicate, sufix: sufix
          end
        end

        def sapi(handler, verb, predicate = nil, sufix = nil, app_name = nil)
          if app_name
            sign = sign_array [handler, verb, predicate], app[:app_name].config.salt
            app_canonical_url app_name, :sapi, sign: sign, handler: handler,
                                               verb: verb, predicate: predicate, sufix: sufix
          else
            sign = sign_array [handler, verb, predicate], app.config.salt
            canonical_url :sapi, sign: sign, handler: handler,
                                 verb: verb, predicate: predicate, sufix: sufix
          end
        end
      end

    end
  end
end

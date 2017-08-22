# frozen_string_literal: true

require 'tzispa/route_set'

module Tzispa
  module Template
    module Rig

      class Router < Tzispa::RouteSet

        def initialize(app, root = nil)
          super app, root, 'Tzispa::Template::Rig'
        end

        def index(path, controller: nil, methods: nil)
          add :index, path, controller || 'layout', methods: methods
        end

        def layout(layout, path, controller: nil, methods: nil)
          add layout, path, controller || 'layout', methods: methods,
                                                    matching: { layout: layout.to_s }
        end

        def api(path, controller: nil, methods: nil)
          add :api, path, controller || 'api', methods: methods
        end

        def signed_api(path, controller: nil, methods: nil)
          add :sapi, path, controller || 'api', methods: methods
        end
      end

    end
  end
end

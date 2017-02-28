# frozen_string_literal: true

require 'yaml'
require 'http_router'
require 'tzispa/utils/string'
require 'tzispa/controller/http_error'

module Tzispa

  class RouteSet
    using Tzispa::Utils

    CONTROLLERS_BASE = 'Tzispa::Controller'

    attr_reader :router, :map_path, :app

    def initialize(app, root = nil)
      @router = HttpRouter.new
      @app = app
      @router.default Controller::HttpError.new(app, :error_404)
      @map_path = root unless root == '/'
    end

    def path(path_id, params = {})
      "#{@map_path}#{@router.path path_id, params}"
    end

    def call(env)
      @router.call env
    end

    def add(route_id, path, controller, methods: nil, matching: nil)
      add_route(route_id, path, to: build_controller(controller),
                                methods: methods,
                                matching: matching)
    end

    def draw
      yield if block_given?
    end

    def index(path, controller: nil, methods: nil)
      add :index, path, controller || 'layout:render!', methods: methods
    end

    def api(path, controller: nil, methods: nil)
      add :api, path, controller || 'api:dispatch!', methods: methods
    end

    def signed_api(path, controller: nil, methods: nil)
      add :sapi, path, controller || 'api:dispatch!', methods: methods
    end

    def layout(layout, path, controller: nil, methods: nil)
      add layout, path, controller || 'layout:render!', methods: methods,
                                                        matching: { layout: layout.to_s }
    end

    private

    def add_route(route_id, path, to:, methods: nil, matching: nil)
      @router.add(path).tap do |rule|
        rule.name = route_id
        rule.to to
        rule.add_request_method(methods) if methods
        rule.add_match_with(matching) if matching
      end
    end

    def build_controller(controller)
      spec_control, callmethod = controller.to_s.split(':')
      mpath = spec_control.split('#')
      controller_class(mpath).new(app, callmethod)
    end

    def controller_class(mpath)
      req_controller = mpath.pop
      cmodule = if mpath.count > 1
                  require "#{app.path}/controller/#{req_controller}"
                  mpath.collect!(&:capitalize).join('::')
                else
                  require "tzispa/controller/#{req_controller}"
                  CONTROLLERS_BASE
                end
      "#{cmodule}::#{req_controller.camelize}".constantize
    end
  end

end

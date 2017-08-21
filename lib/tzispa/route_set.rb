# frozen_string_literal: true

require 'yaml'
require 'http_router'
require 'tzispa/utils/string'
require 'tzispa/controller/http_error'

module Tzispa

  class RouteSet
    using Tzispa::Utils::TzString

    CONTROLLERS_BASE = 'Tzispa::Controller'

    attr_reader :router, :map_path, :app

    def initialize(app, root = nil)
      @router = HttpRouter.new
      @app = app
      @router.default Controller::HttpError.new(app, :error_404)
      @map_path = root unless root == '/'
    end

    def setup
      draw do
        contents = File.read(routes_definitions)
        instance_eval(contents, File.basename(routes_definitions), 0)
      end
    end

    def routes_definitions
      @routes_definitions ||= "config/routes/#{app.name}.rb"
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
      if callmethod
        controller_class(mpath).new(app, callmethod)
      else
        controller_class(mpath).new(app)
      end
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

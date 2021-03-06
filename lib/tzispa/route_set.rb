# frozen_string_literal: true

require 'yaml'
require 'http_router'
require 'tzispa_utils'
require 'tzispa/controller/http_error'

module Tzispa

  class RouteSet
    using Tzispa::Utils::TzString

    CONTROLLERS_BASE = 'Tzispa::Controller'

    attr_reader :router, :map_path, :app

    def initialize(app, root = nil, ctl_module = nil)
      @router = HttpRouter.new
      @app = app
      @router.default Controller::HttpError.new(app, :error_404)
      @map_path = root unless root == '/'
      @ctl_module = ctl_module || CONTROLLERS_BASE
    end

    def setup
      draw do
        contents = File.read(routes_definitions)
        instance_eval(contents, File.basename(routes_definitions), 0)
      end
      self
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

    private

    attr_reader :ctl_module

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
      name = mpath.pop
      "#{require_controller(mpath, name)}::#{name.camelize}".constantize
    end

    def require_controller(mpath, name)
      app_controller(mpath, name) || tz_controller(mpath, name)
    end

    def app_controller(mpath, name)
      ac = "controller/#{mpath.join('/')}/#{name}"
      return unless app.domain.exist? ac
      app.domain.require ac
      mpath.collect(&:capitalize).join('::')
    end

    def tz_controller(mpath, name)
      if mpath.count.positive?
        require "#{ctl_module.underscore}/#{mpath.join('/')}/#{name}"
        [ctl_module, mpath.collect(&:capitalize).join('::')].join('::')
      else
        require "#{ctl_module.underscore}/#{name}"
        ctl_module
      end
    end
  end

end

# frozen_string_literal: true

require 'yaml'
require 'http_router'
require 'tzispa/utils/string'
require 'tzispa/controller/http_error'


module Tzispa

  class Routes

    using Tzispa::Utils

    CONTROLLERS_BASE = 'Tzispa::Controller'

    attr_reader :router, :map_path

    def initialize(app, root=nil)
      @router = HttpRouter.new
      @app = app
      @router.default Tzispa::Controller::HttpError.new(app, :error_404)
      @map_path = root unless root=='/'
    end

    def path(path_id, params={})
      "#{@map_path}#{@router.path path_id, params}"
    end

    def routing(route_id, path, controller, methods: nil, matching: nil)
      spec_control, callmethod = controller.to_s.split(':')
      mpath = spec_control.split('#')
      req_controller = mpath.pop
      controller = req_controller.camelize
      if mpath.count > 1
        controller_module = mpath.collect!{ |w| w.capitalize }.join('::')
        require_relative "./controller/#{req_controller}"
      else
        controller_module = CONTROLLERS_BASE
        require "tzispa/controller/#{req_controller}"
      end
      @router.add(path).tap { |rule|
        rule.to "#{controller_module}::#{controller}".constantize.new(@app, callmethod)
        rule.name = route_id
        rule.add_request_method(methods) if methods
        rule.add_match_with(matching) if matching
      }
    end


    def route_rig_index(path, controller: nil, methods: nil)
      routing :index, path, controller || 'layout:render!', methods: methods
    end

    def route_rig_api(path, controller: nil, methods:nil)
      routing :api, path, controller || 'api:dispatch!', methods: methods
    end

    def route_rig_signed_api(path, controller: nil, methods: nil)
      routing :sapi, path, controller || 'api:dispatch!', methods: methods
    end

    def route_rig_layout(layout, path, controller: nil, methods: nil)
      routing layout, path, controller || 'layout:render!', methods: methods, matching: {layout: layout.to_s}
    end

  end

end

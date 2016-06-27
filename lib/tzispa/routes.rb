# frozen_string_literal: true

require 'yaml'
require 'http_router'
require 'tzispa/utils/string'
require 'tzispa/controller/http_error'

module Tzispa

  class Routes

    CONTROLLERS_BASE = 'Tzispa::Controller'

    attr_reader :router, :map_path

    def initialize(map_path=nil)
      @router = HttpRouter.new
      @router.default Tzispa::Controller::HttpError.new('error_404')
      @map_path = map_path unless map_path=='/'
    end

    def path(path_id, params={})
      "#{@map_path}#{@router.path path_id, params}"
    end

    def add(route_id, path, methods, controller)
      spec_control, callmethod = controller.to_s.split(':')
      mpath = spec_control.split('#')
      req_controller = mpath.pop
      controller = TzString.camelize(req_controller).to_s
      if mpath.count > 1
        controller_module = mpath.collect!{ |w| w.capitalize }.join('::')
        require_relative "./controller/#{req_controller}"
      else
        controller_module = CONTROLLERS_BASE
        require "tzispa/controller/#{req_controller}"
      end
      @router.add(path, methods ? {request_method: methods} : nil ).tap { |rule|
        rule.to TzString.constantize("#{controller_module}::#{controller}").new(callmethod)
        rule.name = route_id
      }
    end

    def index(path, methods=nil, controller=nil)
      add :index, path, methods, controller || 'layout:render!'
    end

    def api(path, methods=nil, controller=nil)
      add :api, path, methods, controller || 'api:dispatch!'
    end

    def signed_api(path, methods=nil, controller=nil)
      add :api, path, methods, controller || 'signed_api:dispatch!'
    end

    def site(path, methods=nil, controller=nil)
      add :site, path, methods, controller || 'layout:render!'
    end

  end

end

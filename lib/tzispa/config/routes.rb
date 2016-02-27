# frozen_string_literal: true

require 'yaml'
require 'http_router'
require 'tzispa/utils/string'

module Tzispa
  module Config
    class Routes

      CONTROLLERS_BASE = 'Tzispa::Controller'

      attr_reader :router, :map_path

      def initialize(map_path=nil)
        @router = HttpRouter.new
        @map_path = map_path unless map_path=='/'
      end

      def path(path_id, params={})
        "#{@map_path}#{@router.path path_id, params}"
      end

      def add(route_id, path, controller)
        spec_control, callmethod = controller.to_s.split(':')
        mpath = spec_control.split('#')
        controller = TzString.camelize(mpath.pop).to_s
        if mpath.count > 1
          controller_module = mpath.collect!{ |w| w.capitalize }.join('::')
          require_relative "./controller/#{controller.downcase}"
        else
          controller_module = CONTROLLERS_BASE
          require "tzispa/controller/#{controller.downcase}"
        end
        @router.add(path).tap { |rule|
          rule.to TzString.constantize("#{controller_module}::#{controller}").new(callmethod)
          rule.name = route_id
        }
      end

      def index(path, controller=nil)
        add :index, path, controller || 'layout:render!'
      end

      def api(path, controller=nil)
        add :api, path, controller || 'api:dispatch!'
      end

      def site(path, controller=nil)
        add :site, path, controller || 'layout:render!'
      end

    end
  end
end

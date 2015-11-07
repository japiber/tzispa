require 'yaml'
require 'http_router'
require 'tzispa/utils/string'

module Tzispa
  module Config
    class Routes

      RPG_ROUTES_FILENAME = :routes

      CONTROLLERS_BASE = 'Tzispa::Controller'.freeze


      def initialize(domain, rtfile=nil)
        @domain = domain
        @router = nil
        @rttime = nil
        @rtfile = rtfile.nil? ? RPG_ROUTES_FILENAME : rtfile
      end

      def filename
        @filename ||= "#{@domain.path}/#{@rtfile}.yml".freeze
      end

      def load!
        if @rttime.nil?
          @rttime = File.ctime(filename)
        else
          if @rttime != File.ctime(filename)
            @router = nil
            @rttime = File.ctime(filename)
          end
        end
        @router ||= Routes.parse(filename, @domain)
      end

      private

      def self.synchronize
        Mutex.new.synchronize do
          yield
        end
      end

      def self.parse(filename, domain)
        synchronize do
          router = HttpRouter.new
          YAML.load(File.open(filename)).each { |key,value|
            spec_control, callmethod = value['controller'].to_s.split(':')
            mpath = spec_control.split('#')
            controller = TzString.camelize(mpath.pop).to_s
            if mpath.count > 1
              controller_module = mpath.collect!{ |w| w.capitalize }.join('::')
              require_relative "./controller/#{controller.downcase}"
            else
              controller_module = CONTROLLERS_BASE
              require "tzispa/controller/#{controller.downcase}"
            end
            rin = router.add(value['path']).to TzString.constantize("#{controller_module}::#{controller}").new(callmethod)
            rin.name = key.to_sym
          }
          router
        end
      end

    end
  end
end

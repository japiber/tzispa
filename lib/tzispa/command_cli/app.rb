require 'json'
require_relative 'project.rb'

module Tzispa
  module CommandCli

    class App


      def create(name, domain, mount_point)
        raise "This command must be runned in a Tzispa project base dir" unless Tzispa::CliCommand::Project.check? 
      end



    end

  end
end

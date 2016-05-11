# frozen_string_literal: true

require 'rack'
require 'browser'

module Tzispa
  module Http
    class Request < Rack::Request

        alias secure? ssl?

        attr_reader :browser

        def initialize(env)
          super(env)
          @browser = Browser.new user_agent, accept_language: env["HTTP_ACCEPT_LANGUAGE"]
        end

        def forwarded?
          @env.include? "HTTP_X_FORWARDED_HOST"
        end

        def safe?
          get? or head? or options? or trace?
        end

        def idempotent?
          safe? or put? or delete? or link? or unlink?
        end

        def link?
          request_method == "LINK"
        end

        def unlink?
          request_method == "UNLINK"
        end

        def browser_is? name
      		name = name.to_s.strip
      		return true if browser_name == name
      		return true if name == 'mozilla' && browser_name == 'gecko'
      		return true if name == 'ie' && browser_name.index('ie')
      		return true if name == 'webkit' && %w{safari chrome iphone ipad ipod}.include?(browser_name)
      		return true if name == 'ios' && %w{iphone ipad ipod}.include?(browser_name)
      		return true if name == 'robots' && %w{googlebot msnbot yahoobot}.include?(browser_name)
      	end

        # Returns the user agent string as determined by the plugin
      	def browser_name
      		@browser_name ||= begin
      			if user_agentindex('msie') && !user_agent.index('opera') && !user_agent.index('webtv')
      				'ie'+user_agent[user_agent.index('msie')+5].chr
      			elsif user_agent.index('gecko/')
      				'gecko'
      			elsif user_agent.index('opera')
      				'opera'
      			elsif user_agent.index('konqueror')
      				'konqueror'
      			elsif user_agent.index('ipod')
      				'ipod'
      			elsif user_agent.index('ipad')
      				'ipad'
      			elsif user_agent.index('iphone')
      				'iphone'
      			elsif user_agent.index('chrome/')
      				'chrome'
      			elsif user_agent.index('applewebkit/')
      				'safari'
      			elsif user_agent.index('googlebot/')
      				'googlebot'
      			elsif user_agent.index('msnbot')
      				'msnbot'
      			elsif user_agent.index('yahoo! slurp')
      				'yahoobot'
      			#Everything thinks it's mozilla, so this goes last
      			elsif user_agent.index('mozilla/')
      				'gecko'
      			else
      				'unknown'
      			end
      		end
      	end

      	# Determine the version of webkit.
      	# Useful for determing rendering capabilties
      	def browser_webkit_version
      		if browser_is? 'webkit'
      			match = user_agent.match(%r{\bapplewebkit/([\d\.]+)\b})
      			if (match)
      				match[1].to_f
      			else
      				nil
      			end
      		else
      			nil
      		end
      	end

        #Gather the user agent and store it for use.
      	def user_agent
      		@ua ||= begin
      			@env['HTTP_USER_AGENT'].downcase
      		rescue
      			''
      		end
      	end

    end
  end
end

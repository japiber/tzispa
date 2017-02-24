# frozen_string_literal: true

require 'rack'

module Tzispa
  module Http

    class Response < Rack::Response

      DROP_BODY_RESPONSES = [204, 205, 304]

      def initialize(*)
        super
        headers['Content-Type'] ||= 'text/html'
      end

      def body=(value)
        value = value.body while Rack::Response === value
        @body = String === value ? [value.to_str] : value
      end

      def each
        block_given? ? super : enum_for(:each)
      end

      def finish
        result = body

        if drop_content_info?
          headers.delete "Content-Length"
          headers.delete "Content-Type"
        end

        if drop_body?
          close
          result = []
        end

        if calculate_content_length?
          # if some other code has already set Content-Length, don't muck with it
          # currently, this would be the static file-handler
          headers["Content-Length"] = body.inject(0) { |l, p| l + p.bytesize }.to_s
        end
        headers['X-Frame-Options'] = 'SAMEORIGIN'
        headers['X-Powered-By'] = "#{Tzispa::FRAMEWORK_NAME} #{Tzispa::VERSION}"
        [status.to_i, headers, result]
      end

      def cache_control
        headers['Cache-control']
      end

      def cache_private
        add_cache_control "private"
        self
      end

      def no_store
        add_cache_control "no-store"
        self
      end

      def no_cache
        add_cache_control "no-cache"
        self
      end

      def must_revalidate
        add_cache_control "must-revalidate"
        self
      end

      def calculate_content_length?
        headers["Content-Type"] and not headers["Content-Length"] and Array === body
      end

      def drop_content_info?
        status.to_i / 100 == 1 or drop_body?
      end

      def drop_body?
        DROP_BODY_RESPONSES.include?(status.to_i)
      end

      private

      def add_cache_control(policy)
        acache = (cache_control || String.new).split(',').map(&:strip)
        acache << policy unless acache.include?(policy)
        headers['Cache-control'] = acache.join(', ')
      end


    end
  end
end

require 'forwardable'

module Tzispa
  module Http

    class SessionFlashBag

      
      extend Forwardable

      def_delegators :@bag, :count, :length, :size, :each

      SESSION_FLASH_BAG = :__flash_bag

      def initialize(session, key)
        @session = session
        @session_key = "#{SESSION_FLASH_BAG}_#{key}".to_sym
        load!
      end

      def << (value)
        if not value.nil?
          @bag << value
          store
        end
      end

      def pop
        value = @bag.pop
        store
        value
      end

      def pop_all
        empty!
        @bag
      end

      def push(value)
        @bag.push value
        store
      end

      private

      def load!
        @bag = @session[@session_key] ? Marshal.load(@session[@session_key]) : Array.new
      end

      def store
        @session[@session_key] = Marshal.dump @bag
      end

      def empty!
        @session[@session_key] = Array.new
      end

    end
  end
end

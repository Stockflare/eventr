module Eventr
  module Receivers
    class Base

      attr_reader :token

      def initialize(token = nil)
        @token = token
      end

      def identity(id, properties)
      end

      def track(id, name, properties = {})
      end

      def control
        @control ||= library
      end

      def library
      end

    end
  end
end

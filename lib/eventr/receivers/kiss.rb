if Object.const_defined? :KMTS
  module Eventr
    module Receivers
      class Kiss < Base

        attr_reader :options

        def initialize(token, options = {})
          super(token)
          @options = options
        end

        def identity(*args)
          kmts.set(*args)
        end

        def track(*args)
          kmts.record(*args)
        end

        def kmts
          @kmts ||= KMTS.init(token, options)
        end

      end
    end
  end
else
  raise 'could not detect mixpanel library'
end

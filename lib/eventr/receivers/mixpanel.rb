if Object.const_defined? :Mixpanel
  module Eventr
    module Receivers
      class Mixpanel < Base

        def identity(*args)
          control.people.set(*args)
        end

        def track(*args)
          control.track(*args)
        end

        def library
          Mixpanel::Tracker.new(token)
        end

      end
    end
  end
else
  raise 'could not detect mixpanel library'
end

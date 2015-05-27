module Eventr
  module Receivers
    if Object.const_defined? :Mixpanel
      class Mixpanel < Base

        def identity(*args)
          tracker.people.set(*args)
        end

        def track(*args)
          tracker.track(*args)
        end

        def tracker
          @tracker ||= Mixpanel::Tracker.new(token)
        end

      end
    else
      raise 'could not detect mixpanel library'
    end
  end
end

module Eventr
  module Track

    extend ActiveSupport::Concern

    included do

      def self.track(key, call = nil)
        call = case call
        when Proc then call
        when Symbol then
          sym = call.to_sym
          -> (a) { send(sym, a) }
        else -> (a) { a }
        end
        define_method(:"#{eventr_methodize_key(key)}!") do |obj = {}|
          eventr_send_event(key.to_s.titleize, instance_exec(obj, &call))
        end
      end

      def self.eventr_methodize_key(key)
        key.to_s.downcase.gsub(' ', '_').underscore.to_sym
      end

    end

    private

    def eventr_send_event(name, properties)
      Eventr.delegate_to_receivers(:track, id, name, properties)
    end

  end
end

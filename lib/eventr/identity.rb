module Eventr
  module Identity

    extend ActiveSupport::Concern

    included do

      self.cattr_accessor :eventr_property_fields
      self.eventr_property_fields = {}

      def self.property(key, call)
        eventr_property_fields[key] = case call
        when Proc then call
        when Symbol then Proc.new { send(call) }
        end
      end

    end

    def to_identity
      identity = eventr_special_properties
      self.class.eventr_property_fields.each do |key, call|
        identity[eventr_scrub_key key] = instance_eval &call
      end
      return identity
    end

    def send_identity
      Eventr.delegate_to_receivers(:identity, id, to_identity)
    end

    alias_method :update_identity, :send_identity

    private

    def eventr_scrub_key(key)
      case key
      when /\$.+/
        key.to_s
      else
        key.to_s.gsub '_', ' '
      end
    end

    def eventr_special_properties
      Eventr::SPECIAL.collect do |key|
        { "$#{key}" => send(key) } if respond_to? key
      end.compact.reduce({}, :merge)
    end

  end
end

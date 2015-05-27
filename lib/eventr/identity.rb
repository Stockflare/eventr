module Eventr
  # Include this module to provide identity support to any class, using
  # a simple DSL to describe properties to be used and how they should be
  # built from the instance.
  #
  # Properties can be defined in a number of different ways, see the example
  # below for all the different possibilities, it should be pretty easy to
  # see and understand how each type of property definition works.
  #
  # This module also automatically includes Special properties (aimed specifically
  # at Mixpanel receivers). Simply define a relevant method, for example #first_name,
  # to have the special property $first_name automatically included within the
  # resulting identity.
  #
  # This module can be included within any class, the only requirement is that
  # the class itself, supports an #id method, or an ident has been set (as in
  # the example below). This is used to uniquely identify the instance of the class.
  # This *should* not be an issue though for database models.
  #
  # @example Defining properties onto a class
  #   This example class includes the Identity module into an ActiveRecord model.
  #   Whilst the class does not have to be a "model", it makes it easier to
  #   provide worked examples.
  #
  #   class User < ActiveRecord::Base
  #
  #     include Eventr::Identity
  #
  #     after_create :send_identity
  #
  #     after_update :update_identity
  #
  #     # name is a model attribute and will be AUTOMATICALLY included as $name
  #
  #     # use a symbol to represent the method to map this property to.
  #     property $email, :encrypted_email
  #
  #     # implicitly map the name of the property to a model attribute
  #     property :favorite_animal
  #
  #     # execute a proc within the context of the class, capitalizing the color
  #     # model attribute.
  #     property :"Favorite Color" do
  #       color.capitalize
  #     end
  #
  #     has_many :toys
  #
  #     property :Number_Of_Toys do
  #       toys.count
  #     end
  #
  #     def encrypted_email
  #       Some::Decryption::Class.new(email)
  #     end
  #
  #   end
  module Identity

    extend ActiveSupport::Concern

    include Ident

    included do

      self.cattr_accessor :eventr_property_fields
      self.eventr_property_fields = {}

      def self.property(key, sym = nil, &call)
        eventr_property_fields[key] = if sym
          Proc.new { send(sym) }
        elsif call
          call
        else
          property(key, eventr_methodize_key(key))
        end
        # eventr_property_fields[key] = case call
        # when Proc then call
        # when nil then property(key, eventr_methodize_key(key))
        # when Symbol then Proc.new { send(call) }
        # else Proc.new { send(call.to_sym) }
        # end
      end

      def self.eventr_methodize_key(key)
        key.to_s.downcase.gsub(' ', '_').underscore.to_sym
      end

    end

    # Use the properties defined on the class to build and return a hash
    # containing all the special and custom properties.
    #
    # @return [Hash] a hash containing all detected properties.
    def to_identity
      identity = eventr_special_properties
      self.class.eventr_property_fields.each do |key, call|
        identity[eventr_scrub_key key] = instance_eval &call
      end
      return identity
    end

    # Sends the identity hash to the receivers to be processed.
    #
    def send_identity
      Eventr.delegate_to_receivers(:identity, ident_id, to_identity)
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

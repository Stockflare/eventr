module Eventr
  # Include this class to enable a simple DSL for tracking and sending events
  # to any registered receivers. You can track events in a number of different
  # ways, coupled with other libraries this can prove to be elegantly flexible.
  #
  # You can either simple define an event to track, like `track :threw_a_ball`
  # or pass a representative method symbol or lamdba, which will handle any input that
  # the event may receive, returning a hash to be sent to the receivers.
  #
  # This module can be included within any class, the only requirement is that
  # the class itself, supports an #id method, or an ident has been set (as in
  # the example below). This is used to uniquely identify the instance of the class.
  # This *should* not be an issue though for database models.
  #
  # @example Simple class, instance tracking
  #   Simple class that enables you to track the event "Game Played" using
  #   an instance method, :game_played!.
  #
  #   class Game
  #
  #     include Eventr::Track
  #
  #     track :game_played
  #
  #     def id
  #       @instance_id
  #     end
  #
  #   end
  #
  # @example Tracking ActiveRecord models
  #   Example of tracking events using an ActiveRecord model.
  #
  #   class User < ActiveRecord::Base
  #
  #     include Eventr::Track
  #
  #     has_many :posts, after_add: :created_post!
  #
  #     track :created_post do |post|
  #       { Title: post.title }
  #     end
  #
  #     track :changed_email do |email|
  #       { "Old Email" => email }
  #     end
  #
  #     def update_email(new_email)
  #       changed_email! email
  #       self.email = email
  #     end
  #
  #   end
  module Track

    extend ActiveSupport::Concern

    include Ident

    included do

      def self.track(key, sym = nil, &block)
        call = if sym
          -> (a) { send(sym.to_sym, a) }
        elsif block
          block
        else
          -> (a) { a }
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
      Eventr.delegate_to_receivers(:track, ident_id, name, properties)
    end

  end
end

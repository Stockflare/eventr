require 'eventr/version'

require 'active_support/concern'
require 'active_support/dependencies/autoload'
require 'active_support/core_ext/module/attribute_accessors'
require 'active_support/core_ext/string/inflections'
require 'active_support/inflector'

module Eventr

  SPECIAL = %i{email phone ios_devices android_devices first_name last_name name}

  extend ActiveSupport::Autoload

  autoload :Identity
  autoload :Ident
  autoload :Track
  autoload :Receivers

  self.cattr_accessor :receivers
  self.receivers = []

  # Delegate an action to all registered receivers
  #
  def self.delegate_to_receivers(action, *args)
    self.receivers.each do |receiver|
      receiver.send(action, *args) if receiver.respond_to? action
    end
  end

  # Helper to configure the Search module.
  #
  # @yield [Search] Yields the {Search} module.
  def self.configure
    yield self
  end

end

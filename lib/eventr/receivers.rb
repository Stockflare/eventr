module Eventr
  module Receivers

    extend ActiveSupport::Autoload

    autoload :Base

    # Alias for initializing the simple base class.
    # Performs no actions on any methods invoked on it, useful
    # for testing purposes.
    autoload :Null

    # The 'mixpanel-ruby' gem must be included before
    # this Class definition will load successfully.
    # Ensure that the gem is included within your
    # Gemfile or Gemspec.
    #
    # @see https://github.com/mixpanel/mixpanel-ruby
    autoload :Mixpanel

    # The 'kmts' gem must be included before this class will
    # work properly. This receiver will send events and identities
    # to Kiss Metrics.
    #
    # @see https://github.com/kissmetrics/kmts
    autoload :Kiss

  end
end

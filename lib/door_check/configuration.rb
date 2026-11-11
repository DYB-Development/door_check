require "door_check/methods"

module DoorCheck
  class UnknownMethod < StandardError; end

  class Configuration
    attr_reader :offered_methods

    def offered_methods=(names)
      unknown = names - Methods.names
      raise UnknownMethod, "door_check does not know the sign-in method #{unknown.join(', ')}" if unknown.any?

      @offered_methods = names
    end
  end
end

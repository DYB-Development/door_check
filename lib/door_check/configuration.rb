require "door_check/methods"

module DoorCheck
  class UnknownMethod < StandardError; end

  class Configuration
    attr_reader :offered_methods
    attr_accessor :person_method, :account_method

    def offered_methods=(names)
      unknown = names - Methods.names
      raise UnknownMethod, "door_check does not know the sign-in method #{unknown.join(', ')}" if unknown.any?

      @offered_methods = names
    end
  end
end

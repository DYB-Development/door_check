require "door_check/methods"

module DoorCheck
  class UnknownMethod < StandardError; end

  class Configuration
    attr_reader :offered_methods
    attr_accessor :person_method, :account_method, :parent_controller, :parent_mailer, :existing_authenticator, :person_accounts,
                  :find_person_by_email, :sign_in_person, :sign_out_person, :passkey_domain, :locate_ip, :stylesheet

    def initialize
      @parent_controller = "::ApplicationController"
      @parent_mailer = "::ApplicationMailer"
      @stylesheet = "application"
    end

    def offered_methods=(names)
      unknown = names - Methods.names
      raise UnknownMethod, "door_check does not know the sign-in method #{unknown.join(', ')}" if unknown.any?

      @offered_methods = names
    end

    def authenticator
      existing_authenticator&.constantize&.new
    end
  end
end

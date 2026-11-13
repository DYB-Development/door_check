module DoorCheck
  module SecondStep
    Setup = Data.define(:method_name, :label, :page, :request_method, :before_second_step)

    SETUPS = [
      Setup.new(:authenticator_app, "Set up an authenticator app", :new_authenticator_path, :get, true),
      Setup.new(:passkey, "Add a passkey or hardware key", :new_passkey_path, :get, false),
      Setup.new(:backup_codes, "Make new backup codes", :backup_codes_path, :post, false)
    ].freeze

    def self.set_up?(person)
      Credential.exists?(person: person, method_name: %w[authenticator_app backup_codes passkey]) || DoorCheck.configuration.authenticator&.set_up?(person)
    end

    def self.offered_setups
      SETUPS.select { |setup| DoorCheck.configuration.offered_methods.include?(setup.method_name) }
    end

    def self.setups_before_second_step(account)
      rule = account && AccountRule.for(account)
      offered_setups.select { |setup| setup.before_second_step && (rule.nil? || rule.accepts?(setup.method_name)) }
    end
  end
end

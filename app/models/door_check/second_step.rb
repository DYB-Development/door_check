module DoorCheck
  module SecondStep
    SETUP_PAGES = { authenticator_app: :new_authenticator_path }.freeze

    def self.set_up?(person)
      Credential.exists?(person: person, method_name: "authenticator_app") || DoorCheck.configuration.authenticator&.set_up?(person)
    end

    def self.offered_setups(account)
      rule = account && AccountRule.for(account)
      SETUP_PAGES.select { |method_name, _| DoorCheck.configuration.offered_methods.include?(method_name) && (rule.nil? || rule.accepts?(method_name)) }
    end
  end
end

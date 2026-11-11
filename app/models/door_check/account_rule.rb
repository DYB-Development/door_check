module DoorCheck
  class AccountRule < ApplicationRecord
    belongs_to :account, polymorphic: true

    def self.for(account)
      find_or_initialize_by(account: account)
    end

    def met_by?(method_names)
      used = accepted_among(method_names)
      return false if accepted_methods && used.empty?

      !second_step_required || used.any? { |name| Methods.roles(name).include?(:second_step) }
    end

    def accepts?(method_name)
      accepted_methods.nil? || accepted_methods.map(&:to_sym).include?(method_name.to_sym)
    end

    private

    def accepted_among(method_names)
      return method_names unless accepted_methods

      method_names & accepted_methods.map(&:to_sym)
    end
  end
end

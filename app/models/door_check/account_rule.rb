module DoorCheck
  class AccountRule < ApplicationRecord
    belongs_to :account, polymorphic: true

    def self.for(account)
      find_or_initialize_by(account: account)
    end

    def met_by?(method_names)
      !second_step_required || method_names.any? { |name| Methods.roles(name).include?(:second_step) }
    end
  end
end

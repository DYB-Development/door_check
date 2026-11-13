module DoorCheck
  class PersonRule < ApplicationRecord
    belongs_to :person, polymorphic: true

    def self.for(person)
      find_or_initialize_by(person: person)
    end

    def met_by?(method_names, account: nil)
      !in_force_in?(account) || method_names.any? { |name| Methods.roles(name).include?(:second_step) }
    end

    def in_force_in?(account)
      second_step_required && may_choose_in?(account)
    end

    def may_choose_in?(account)
      DoorCheck.configuration.people_choose_second_step && (account.nil? || AccountRule.for(account).members_choose_second_step)
    end
  end
end

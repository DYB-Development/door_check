module DoorCheck
  class PersonRule < ApplicationRecord
    belongs_to :person, polymorphic: true

    def self.for(person)
      find_or_initialize_by(person: person)
    end

    def met_by?(method_names)
      !second_step_required || method_names.any? { |name| Methods.roles(name).include?(:second_step) }
    end
  end
end

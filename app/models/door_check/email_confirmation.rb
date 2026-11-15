module DoorCheck
  class EmailConfirmation < ApplicationRecord
    belongs_to :person, polymorphic: true

    def self.for(person)
      find_or_initialize_by(person: person)
    end

    def self.confirmed?(person, email)
      self.for(person).confirmed_at.present?
    end

    def confirm(email)
      update!(email: email, confirmed_at: Time.current)
    end
  end
end

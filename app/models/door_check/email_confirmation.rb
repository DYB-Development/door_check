module DoorCheck
  class EmailConfirmation < ApplicationRecord
    belongs_to :person, polymorphic: true

    def self.for(person)
      find_or_initialize_by(person: person)
    end

    def self.confirmed?(person, email)
      confirmation = self.for(person)
      confirmation.confirmed_at.present? && confirmation.email == email
    end

    def confirm(email)
      update!(email: email, confirmed_at: Time.current)
    end
  end
end

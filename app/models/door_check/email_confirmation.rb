module DoorCheck
  class EmailConfirmation < ApplicationRecord
    belongs_to :person, polymorphic: true

    def self.for(person)
      find_or_initialize_by(person: person)
    end

    def self.confirmed?(person, email) = self.for(person).confirms?(email)

    def awaiting? = email.present? && !confirms?(current_address)

    def confirms?(address) = confirmed_at.present? && email.to_s.casecmp?(address.to_s.strip)

    def current_address = person.respond_to?(:email) ? person.email : email

    def confirm(email)
      update!(email: email, confirmed_at: Time.current)
    end
  end
end

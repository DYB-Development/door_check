module DoorCheck
  class Credential < ApplicationRecord
    belongs_to :person, polymorphic: true

    def verify(code)
      ROTP::TOTP.new(secret).verify(code, drift_behind: 15).present?
    end
  end
end

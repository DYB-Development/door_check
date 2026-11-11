module DoorCheck
  class Credential < ApplicationRecord
    belongs_to :person, polymorphic: true

    encrypts :secret

    def verify(code)
      return false unless ROTP::TOTP.new(secret).verify(code, drift_behind: 15)

      update!(last_used_at: Time.current)
    end
  end
end

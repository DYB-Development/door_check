module DoorCheck
  class TrustedDevice < ApplicationRecord
    LIFETIME = 30.days

    belongs_to :person, polymorphic: true

    def self.trust(person, device:)
      token = SecureRandom.urlsafe_base64(32)
      create!(person: person, device: device, token_digest: KeyedDigest.of(token), expires_at: LIFETIME.from_now)
      token
    end

    def self.recognise(person, token)
      find_by(person: person, token_digest: KeyedDigest.of(token))
    end
  end
end

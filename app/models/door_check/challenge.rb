module DoorCheck
  class Challenge < ApplicationRecord
    LIFETIME = 15.minutes
    APPROVAL_LIFETIME = 5.minutes

    belongs_to :person, polymorphic: true

    attr_accessor :code, :token

    def self.issue(person)
      code = format("%06d", SecureRandom.random_number(1_000_000))
      token = SecureRandom.urlsafe_base64(32)
      create!(person: person, code: code, token: token, code_digest: digest(code), token_digest: digest(token), expires_at: LIFETIME.from_now)
    end

    def self.request_approval(person, device:, ip_address:)
      create!(person: person, number: format("%02d", SecureRandom.random_number(10..99)), device: device, ip_address: ip_address,
              expires_at: APPROVAL_LIFETIME.from_now)
    end

    def self.digest(value) = KeyedDigest.of(value)

    def self.redeem_token(token)
      challenge = find_by(token_digest: digest(token))
      challenge if challenge&.use
    end

    def redeem_code(code)
      ActiveSupport::SecurityUtils.secure_compare(code_digest, self.class.digest(code)) && use
    end

    def use
      self.class.where(id: id, used_at: nil).where("expires_at > ?", Time.current).update_all(used_at: Time.current) == 1
    end
  end
end

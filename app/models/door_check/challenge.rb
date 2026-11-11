module DoorCheck
  class Challenge < ApplicationRecord
    LIFETIME = 15.minutes

    belongs_to :person, polymorphic: true

    attr_accessor :code, :token

    def self.issue(person)
      code = format("%06d", SecureRandom.random_number(1_000_000))
      token = SecureRandom.urlsafe_base64(32)
      create!(person: person, code: code, token: token, code_digest: digest(code), token_digest: digest(token), expires_at: LIFETIME.from_now)
    end

    def self.digest(value)
      OpenSSL::HMAC.hexdigest("SHA256", Rails.application.secret_key_base, value.to_s)
    end

    def redeem_code(code)
      ActiveSupport::SecurityUtils.secure_compare(code_digest, self.class.digest(code)) && use
    end

    private

    def use
      self.class.where(id: id, used_at: nil).update_all(used_at: Time.current) == 1
    end
  end
end

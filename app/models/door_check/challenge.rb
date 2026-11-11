module DoorCheck
  class Challenge < ApplicationRecord
    LIFETIME = 15.minutes

    belongs_to :person, polymorphic: true

    attr_reader :code, :token

    def self.issue(person)
      code = format("%06d", SecureRandom.random_number(1_000_000))
      token = SecureRandom.urlsafe_base64(32)
      create!(person: person, code_digest: digest(code), token_digest: digest(token), expires_at: LIFETIME.from_now).tap do |challenge|
        challenge.instance_variable_set(:@code, code)
        challenge.instance_variable_set(:@token, token)
      end
    end

    def self.digest(value)
      OpenSSL::HMAC.hexdigest("SHA256", Rails.application.secret_key_base, value.to_s)
    end

    def redeem_code(code)
      ActiveSupport::SecurityUtils.secure_compare(code_digest, self.class.digest(code))
    end
  end
end

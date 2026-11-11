module DoorCheck
  module KeyedDigest
    def self.of(value)
      OpenSSL::HMAC.hexdigest("SHA256", Rails.application.secret_key_base, value.to_s)
    end
  end
end

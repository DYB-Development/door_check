module DoorCheck
  module Passkeys
    def self.user_handle(person)
      Base64.urlsafe_encode64(KeyedDigest.of(person.to_global_id)[0, 32], padding: false)
    end
  end
end

module DoorCheck
  module BackupCodes
    METHOD_NAME = "backup_codes".freeze
    COUNT = 10

    def self.create_for(person)
      codes = Array.new(COUNT) { SecureRandom.alphanumeric(10).downcase }
      Credential.transaction do
        Credential.where(person: person, method_name: METHOD_NAME).delete_all
        Credential.create!(person: person, method_name: METHOD_NAME, secret: codes.map { |code| KeyedDigest.of(code) }.to_json)
      end
      codes
    end

    def self.use(person, code)
      Credential.transaction do
        credential = Credential.lock.find_by(person: person, method_name: METHOD_NAME)
        digests = credential ? JSON.parse(credential.secret) : []
        digest = KeyedDigest.of(code.to_s.strip.downcase)
        next false unless digests.include?(digest)

        credential.update!(secret: (digests - [ digest ]).to_json, last_used_at: Time.current)
      end
    end
  end
end

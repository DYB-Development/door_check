module DoorCheck
  class Credential < ApplicationRecord
    belongs_to :person, polymorphic: true

    encrypts :secret

    def label = method_name.humanize

    def last_used = last_used_at&.to_fs(:long) || "Not used yet"

    def accepted_by
      DoorCheck.configuration.person_accounts.call(person).select { |account| AccountRule.for(account).accepts?(method_name) }.map(&:name).to_sentence
    end

    def verify(code)
      used_at = ROTP::TOTP.new(secret).verify(code, drift_behind: 15, after: last_used_at)
      return false unless used_at

      update!(last_used_at: Time.zone.at(used_at))
    end
  end
end

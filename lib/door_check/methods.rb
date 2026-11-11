module DoorCheck
  module Methods
    ROLES = {
      password: %i[sign_in],
      email_code: %i[sign_in],
      email_link: %i[sign_in],
      device_approval: %i[sign_in],
      authenticator_app: %i[second_step],
      sms_code: %i[second_step],
      passkey: %i[sign_in second_step],
      backup_codes: %i[second_step],
      trusted_device: %i[second_step],
      google: %i[sign_in],
      apple: %i[sign_in],
      sso: %i[sign_in]
    }.freeze

    def self.names = ROLES.keys
  end
end

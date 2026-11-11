module DoorCheck
  class PasskeySignInsController < ApplicationController
    include PasskeyCeremony

    def new
      @options = remember_passkey_challenge(passkey_relying_party.options_for_authentication(user_verification: "required"))
    end

    def create
      _, credential = passkey_relying_party.verify_authentication(submitted_passkey, take_passkey_challenge, user_verification: true) do |passkey|
        Credential.find_by!(method_name: "passkey", external_id: passkey.id)
      end
      DoorCheck.configuration.sign_in_person.call(self, credential.person)
      door_check_signed_in(credential.person, method_name: :passkey)
      redirect_to "/"
    end
  end
end

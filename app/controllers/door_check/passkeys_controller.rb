module DoorCheck
  class PasskeysController < ApplicationController
    include PasskeyCeremony

    def new
      @options = remember_passkey_challenge(passkey_relying_party.options_for_registration(
        user: { id: Passkeys.user_handle(door_check_person), name: door_check_person.try(:email).to_s },
        authenticator_selection: { resident_key: "preferred", user_verification: "preferred" }
      ))
    end

    def create
      passkey = passkey_relying_party.verify_registration(submitted_passkey, take_passkey_challenge)
      Credential.create!(person: door_check_person, method_name: "passkey", name: params[:name].to_s.strip,
                         external_id: passkey.id, public_key: passkey.public_key, sign_count: passkey.sign_count)
      redirect_to session.delete(EntryCheck::RETURN_KEY) || "/"
    end
  end
end

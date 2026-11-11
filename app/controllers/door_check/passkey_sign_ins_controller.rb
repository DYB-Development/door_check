module DoorCheck
  class PasskeySignInsController < ApplicationController
    before_action { head :not_found unless DoorCheck.configuration.offered_methods.include?(:passkey) }
    include PasskeyCeremony

    def new
      prepare_sign_in
    end

    def create
      passkey, credential = passkey_relying_party.verify_authentication(submitted_passkey, take_passkey_challenge, user_verification: true) do |answer|
        Credential.find_by!(method_name: "passkey", external_id: answer.id)
      end
      credential.update!(sign_count: passkey.sign_count, last_used_at: Time.current)
      DoorCheck.configuration.sign_in_person.call(self, credential.person)
      door_check_signed_in(credential.person, method_name: :passkey)
      redirect_to "/"
    rescue WebAuthn::Error, JSON::ParserError, ActiveRecord::RecordNotFound
      @error = "That passkey could not sign you in. Use one that asks for your fingerprint, face or PIN."
      prepare_sign_in
      render :new, status: :unprocessable_content
    end

    private

    def prepare_sign_in
      @options = remember_passkey_challenge(passkey_relying_party.options_for_authentication(user_verification: "required"))
    end
  end
end

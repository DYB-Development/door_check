module DoorCheck
  class SecondStepsController < ApplicationController
    include PasskeyCeremony

    before_action :find_authenticator

    def new
      prepare_passkey
    end

    def create
      method_name = verify_code(params[:code].to_s.strip)
      return refuse(code_refusal) unless method_name

      prove(method_name)
    end

    def passkey
      answer, credential = passkey_relying_party.verify_authentication(submitted_passkey, take_passkey_challenge, user_verification: false) do |submitted|
        Credential.find_by!(person: @person, method_name: "passkey", external_id: submitted.id)
      end
      credential.update!(sign_count: answer.sign_count, last_used_at: Time.current)
      prove(:passkey)
    rescue WebAuthn::Error, JSON::ParserError, ActiveRecord::RecordNotFound
      refuse("That passkey or key did not work. Try again or enter a code.")
    end

    private

    def find_authenticator
      @person = door_check_person
      @authenticator = DoorCheck.configuration.authenticator
      @second_step_set_up = SecondStep.set_up?(@person)
      @setups = SecondStep.setups_before_second_step(door_check_account)
    end

    def prepare_passkey
      passkey_ids = Credential.where(person: @person, method_name: "passkey").pluck(:external_id)
      return if passkey_ids.empty?

      @passkey_options = remember_passkey_challenge(passkey_relying_party.options_for_authentication(allow: passkey_ids, user_verification: "preferred"))
    end

    def prove(method_name)
      door_check_session.prove!(method_name)
      trust_browser if params[:trust_browser] == "1" && DoorCheck.configuration.offered_methods.include?(:trusted_device)
      redirect_to session.delete(EntryCheck::RETURN_KEY) || "/"
    end

    def trust_browser
      token = TrustedDevice.trust(@person, device: request.user_agent.to_s.truncate(255))
      cookies.signed[TrustedDevice::COOKIE] = { value: token, expires: TrustedDevice::LIFETIME, httponly: true, secure: request.ssl?, same_site: :lax }
    end

    def verify_code(code)
      return :authenticator_app if Credential.where(person: @person, method_name: "authenticator_app").any? { |credential| credential.verify(code) }
      return :backup_codes if BackupCodes.use(@person, code)

      @authenticator&.verify(@person, code)
    end

    def code_refusal = "That code is not right. Check your authenticator app and try again."

    def refuse(message)
      @error = message
      prepare_passkey
      render :new, status: :unprocessable_content
    end
  end
end

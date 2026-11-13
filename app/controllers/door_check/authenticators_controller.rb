require "base64"

module DoorCheck
  class AuthenticatorsController < ApplicationController
    PENDING_SECRET_KEY = :door_check_pending_authenticator_secret

    include ExistingSecondStep

    def new
      session[PENDING_SECRET_KEY] ||= ROTP::Base32.random
      draw_qr_code
    end

    def create
      return restart_setup unless session[PENDING_SECRET_KEY]

      credential = Credential.new(person: door_check_person, method_name: "authenticator_app", secret: session[PENDING_SECRET_KEY])
      return refuse_code unless credential.verify(params[:code].to_s.strip)

      session.delete(PENDING_SECRET_KEY)
      door_check_session&.prove!(:authenticator_app)
      redirect_to session.delete(EntryCheck::RETURN_KEY) || "/"
    end

    private

    def restart_setup
      redirect_to new_authenticator_path,
                  alert: "Setup started again with a new key. Scan the new code or enter the new key in your authenticator app."
    end

    def refuse_code
      @error = "That code is not right. Check your authenticator app and try again."
      draw_qr_code
      render :new, status: :unprocessable_content
    end

    def draw_qr_code
      @secret_key = session[PENDING_SECRET_KEY]
      @spaced_secret_key = @secret_key.scan(/.{1,4}/).join(" ")
      svg = RQRCode::QRCode.new(provisioning_uri).as_svg(module_size: 4, use_path: true)
      @qr_code_url = "data:image/svg+xml;base64,#{Base64.strict_encode64(svg)}"
    end

    def provisioning_uri
      ROTP::TOTP.new(session[PENDING_SECRET_KEY], issuer: DoorCheck.configuration.authenticator_issuer)
                .provisioning_uri(door_check_person.try(:email).to_s)
    end
  end
end

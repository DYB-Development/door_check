module DoorCheck
  class AuthenticatorsController < ApplicationController
    PENDING_SECRET_KEY = :door_check_pending_authenticator_secret

    def new
      session[PENDING_SECRET_KEY] = ROTP::Base32.random
      @qr_code = RQRCode::QRCode.new(provisioning_uri).as_svg(module_size: 4, use_path: true)
    end

    private

    def provisioning_uri
      ROTP::TOTP.new(session[PENDING_SECRET_KEY], issuer: Rails.application.class.module_parent_name)
                .provisioning_uri(door_check_person.try(:email).to_s)
    end
  end
end

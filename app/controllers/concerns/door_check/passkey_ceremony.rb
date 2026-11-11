module DoorCheck
  module PasskeyCeremony
    CHALLENGE_KEY = :door_check_passkey_challenge

    private

    def passkey_relying_party
      WebAuthn::RelyingParty.new(origin: request.base_url, id: DoorCheck.configuration.passkey_domain || request.host,
                                 name: Rails.application.class.module_parent_name)
    end

    def remember_passkey_challenge(options)
      session[CHALLENGE_KEY] = options.challenge
      options
    end

    def take_passkey_challenge = session.delete(CHALLENGE_KEY)

    def submitted_passkey = JSON.parse(params[:credential].to_s)
  end
end

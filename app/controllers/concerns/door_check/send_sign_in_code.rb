module DoorCheck
  module SendSignInCode
    def door_check_send_sign_in_code(person, email)
      challenge = Challenge.issue(person, email: email)
      SignInMailer.code_and_link(challenge, to: email).deliver_now
      session[EmailSignInsController::CHALLENGE_KEY] = challenge.id
    end
  end
end

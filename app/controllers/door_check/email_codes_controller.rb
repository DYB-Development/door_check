module DoorCheck
  class EmailCodesController < ApplicationController
    def create
      challenge = Challenge.find_by(id: session[EmailSignInsController::CHALLENGE_KEY])
      return unless challenge&.redeem_code(params[:code].to_s.strip)

      session.delete(EmailSignInsController::CHALLENGE_KEY)
      DoorCheck.configuration.sign_in_person.call(self, challenge.person)
      door_check_signed_in(challenge.person, method_name: :email_code)
      redirect_to "/"
    end
  end
end

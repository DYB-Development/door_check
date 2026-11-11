module DoorCheck
  class EmailCodesController < ApplicationController
    before_action { head :not_found unless DoorCheck.configuration.offered_methods.include?(:email_code) }

    def new
    end

    def create
      challenge = Challenge.find_by(id: session[EmailSignInsController::CHALLENGE_KEY])
      return refuse_code unless challenge&.redeem_code(params[:code].to_s.strip)

      session.delete(EmailSignInsController::CHALLENGE_KEY)
      DoorCheck.configuration.sign_in_person.call(self, challenge.person)
      door_check_signed_in(challenge.person, method_name: :email_code)
      redirect_to "/"
    end

    private

    def refuse_code
      @error = "That code is not right, or it has expired. Check the email we sent or ask for a new code."
      render :new, status: :unprocessable_content
    end
  end
end

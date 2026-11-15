module DoorCheck
  class SignUpsController < ApplicationController
    before_action { head :not_found unless sign_up_offered? }

    def new
    end

    def create
      DoorCheck.configuration.sign_up_person.call(self, submitted_values)
      send_code(params[:email].to_s.strip)
      redirect_to door_check.new_email_code_path
    end

    private

    def submitted_values
      params.to_unsafe_h.except(:controller, :action, :authenticity_token)
    end

    def send_code(email)
      challenge = Challenge.issue(DoorCheck.configuration.find_person_by_email.call(email))
      SignInMailer.code_and_link(challenge, to: email).deliver_now
      session[EmailSignInsController::CHALLENGE_KEY] = challenge.id
    end

    def sign_up_offered?
      DoorCheck.configuration.sign_up_person && DoorCheck.configuration.offered_methods.include?(:email_code)
    end
  end
end

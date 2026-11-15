module DoorCheck
  class EmailSignInsController < ApplicationController
    include SendSignInCode

    CHALLENGE_KEY = :door_check_challenge_id

    before_action { head :not_found unless DoorCheck.configuration.offered_methods.include?(:email_code) }

    def new
    end

    def create
      email = params[:email].to_s.strip
      person = DoorCheck.configuration.find_person_by_email.call(email)
      if person
        door_check_send_sign_in_code(person, email)
      else
        session[CHALLENGE_KEY] = nil
      end
      redirect_to door_check.new_email_code_path
    end
  end
end

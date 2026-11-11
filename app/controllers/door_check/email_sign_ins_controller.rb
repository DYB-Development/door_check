module DoorCheck
  class EmailSignInsController < ApplicationController
    CHALLENGE_KEY = :door_check_challenge_id

    def create
      email = params[:email].to_s.strip
      person = DoorCheck.configuration.find_person_by_email.call(email)
      challenge = Challenge.issue(person)
      session[CHALLENGE_KEY] = challenge.id
      SignInMailer.code_and_link(challenge, to: email).deliver_now
      redirect_to door_check.new_email_code_path
    end
  end
end

module DoorCheck
  class EmailSignInsController < ApplicationController
    CHALLENGE_KEY = :door_check_challenge_id

    before_action { head :not_found unless DoorCheck.configuration.offered_methods.include?(:email_code) }

    def new
    end

    def create
      email = params[:email].to_s.strip
      person = DoorCheck.configuration.find_person_by_email.call(email)
      session[CHALLENGE_KEY] = person && send_code(person, email).id
      redirect_to door_check.new_email_code_path
    end

    private

    def send_code(person, email)
      Challenge.issue(person).tap { |challenge| SignInMailer.code_and_link(challenge, to: email).deliver_now }
    end
  end
end

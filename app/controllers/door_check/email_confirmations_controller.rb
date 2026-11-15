module DoorCheck
  class EmailConfirmationsController < ApplicationController
    def show
      challenge = Challenge.redeem_token(params[:token], purpose: "confirm")
      return render(:expired, status: :not_found) unless challenge

      EmailConfirmation.for(challenge.person).confirm(challenge.email)
    end

    def create
      confirmation = EmailConfirmation.for(door_check_person)
      SignInMailer.confirmation(Challenge.issue_confirmation(confirmation.person, confirmation.email)).deliver_now
      render :sent
    end
  end
end

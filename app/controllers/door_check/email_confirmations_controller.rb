module DoorCheck
  class EmailConfirmationsController < ApplicationController
    def show
      challenge = Challenge.redeem_token(params[:token], purpose: "confirm")
      return render(:expired, status: :not_found) unless challenge

      EmailConfirmation.for(challenge.person).confirm(challenge.email)
    end

    def create
      earlier = Challenge.find_by(token_digest: Challenge.digest(params[:token].to_s), purpose: "confirm") if params[:token]
      confirmation = earlier || EmailConfirmation.for(door_check_person)
      SignInMailer.confirmation(Challenge.issue_confirmation(confirmation.person, confirmation.email)).deliver_now
      render :sent
    end
  end
end

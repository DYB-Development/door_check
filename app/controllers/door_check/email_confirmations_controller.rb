module DoorCheck
  class EmailConfirmationsController < ApplicationController
    def show
      challenge = Challenge.redeem_token(params[:token], purpose: "confirm")
      return render(:expired, status: :not_found) unless challenge

      challenge.confirm_address
    end

    def create
      earlier = Challenge.find_by(token_digest: Challenge.digest(params[:token].to_s), purpose: "confirm") if params[:token]
      confirmation = earlier || EmailConfirmation.for(door_check_person)
      return head(:not_found) if confirmation.email.blank?

      SignInMailer.confirmation(Challenge.issue_confirmation(confirmation.person, confirmation.email)).deliver_now
      render :sent
    end
  end
end

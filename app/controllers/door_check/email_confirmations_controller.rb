module DoorCheck
  class EmailConfirmationsController < ApplicationController
    def show
      challenge = Challenge.redeem_token(params[:token], purpose: "confirm")
      return render(:expired, status: :not_found) unless challenge

      EmailConfirmation.for(challenge.person).confirm(challenge.email)
    end
  end
end

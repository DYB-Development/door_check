module DoorCheck
  class EmailChangesController < ApplicationController
    def show
      challenge = Challenge.redeem_token(params[:token], purpose: "change_email")
      DoorCheck.configuration.email_change_confirmed.call(self, challenge.person, challenge.email)
      EmailConfirmation.for(challenge.person).confirm(challenge.email)
    end
  end
end

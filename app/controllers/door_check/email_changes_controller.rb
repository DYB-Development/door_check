module DoorCheck
  class EmailChangesController < ApplicationController
    def show
      challenge = Challenge.redeem_token(params[:token], purpose: "change_email")
      result = DoorCheck.configuration.email_change_confirmed.call(self, challenge.person, challenge.email)
      return refuse(result.message) unless result.ok?

      EmailConfirmation.for(challenge.person).confirm(challenge.email)
    end

    private

    def refuse(message)
      @message = message
      render :refused, status: :unprocessable_content
    end
  end
end

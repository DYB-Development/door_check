module DoorCheck
  class EmailLinksController < ApplicationController
    def show
      challenge = Challenge.redeem_token(params[:token])

      DoorCheck.configuration.sign_in_person.call(self, challenge.person)
      door_check_signed_in(challenge.person, method_name: :email_link)
      redirect_to "/"
    end
  end
end

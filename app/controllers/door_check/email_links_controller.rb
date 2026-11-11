module DoorCheck
  class EmailLinksController < ApplicationController
    before_action { head :not_found unless DoorCheck.configuration.offered_methods.include?(:email_link) }

    def show
      challenge = Challenge.redeem_token(params[:token])
      return render(:expired, status: :not_found) unless challenge

      DoorCheck.configuration.sign_in_person.call(self, challenge.person)
      door_check_signed_in(challenge.person, method_name: :email_link)
      redirect_to "/"
    end
  end
end

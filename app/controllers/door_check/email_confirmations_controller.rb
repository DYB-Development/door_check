module DoorCheck
  class EmailConfirmationsController < ApplicationController
    def show
      challenge = Challenge.redeem_token(params[:token], purpose: "confirm")
      return render(:expired, status: :not_found) unless challenge

      challenge.confirm_address
    end

    def create
      person, address = resend_target
      return head(:not_found) if address.blank?

      SignInMailer.confirmation(Challenge.issue_confirmation(person, address)).deliver_now
      render :sent
    end

    private

    def resend_target
      earlier = Challenge.for_token(params[:token].to_s, purpose: "confirm") if params[:token]
      return [ earlier.person, earlier.email ] if earlier

      [ door_check_person, EmailConfirmation.for(door_check_person).current_address ]
    end
  end
end

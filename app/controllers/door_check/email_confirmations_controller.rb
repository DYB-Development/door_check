module DoorCheck
  class EmailConfirmationsController < ApplicationController
    rate_limit to: 5, within: 1.hour, only: :create, by: :resend_limit_key,
               with: -> { render :limited, status: :too_many_requests }

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

    def resend_limit_key
      person, = resend_target
      person ? person.to_global_id.to_s : request.remote_ip
    end

    def resend_target
      @resend_target ||= begin
        earlier = Challenge.for_token(params[:token].to_s, purpose: "confirm") if params[:token]
        earlier ? [ earlier.person, earlier.email ] : [ door_check_person, EmailConfirmation.for(door_check_person).current_address ]
      end
    end
  end
end

module DoorCheck
  class EmailChangesController < ApplicationController
    NOT_CHANGED = "Your email address could not be changed. Ask for the change again in a moment."

    def show
      challenge = Challenge.redeem_token(params[:token], purpose: "change_email")
      return render(:expired, status: :not_found) unless challenge

      result = email_change_confirmed(challenge)
      return refuse(result.message) unless result.ok?

      EmailConfirmation.for(challenge.person).confirm(challenge.email)
    end

    def cancel
      challenge = Challenge.redeem_token(params[:token], purpose: "cancel_email_change")
      email_change_cancelled(challenge)
      render :cancelled
    end

    private

    def email_change_cancelled(challenge)
      DoorCheck.configuration.email_change_cancelled.call(self, challenge.person, challenge.email)
    rescue StandardError => error
      Rails.error.report(error)
    end

    def email_change_confirmed(challenge)
      DoorCheck.configuration.email_change_confirmed.call(self, challenge.person, challenge.email)
    rescue StandardError => error
      Rails.error.report(error)
      Result.new(ok: false, message: NOT_CHANGED)
    end

    def refuse(message)
      @message = message.presence || NOT_CHANGED
      render :refused, status: :unprocessable_content
    end
  end
end

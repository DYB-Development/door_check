module DoorCheck
  class RequestEmailChange
    def initialize(person:, account:, values:)
      @person = person
      @account = account
      @values = values
    end

    def call
      return Result.new(ok: false, message: "Enter the new email address.") if @values[:email].blank?

      SignInMailer.email_change_confirmation(Challenge.issue_email_change(@person, @values[:email])).deliver_now
      send_notice(@person.try(:email))
      Result.new(ok: true)
    end

    private

    def send_notice(current_email)
      return if current_email.blank?

      SignInMailer.email_change_notice(Challenge.issue_email_change_cancel(@person, @values[:email]), to: current_email).deliver_now
    end
  end
end

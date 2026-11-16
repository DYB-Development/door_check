module DoorCheck
  class RequestEmailChange
    def initialize(person:, account:, values:)
      @person = person
      @account = account
      @values = values
    end

    def call
      SignInMailer.email_change_confirmation(Challenge.issue_email_change(@person, @values[:email])).deliver_now
      Result.new(ok: true)
    end
  end
end

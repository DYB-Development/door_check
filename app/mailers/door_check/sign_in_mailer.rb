module DoorCheck
  class SignInMailer < ApplicationMailer
    def code_and_link(challenge, to:)
      @code = challenge.code
      mail to: to, subject: "Your sign-in code"
    end
  end
end

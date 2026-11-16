module DoorCheck
  class SignInMailer < DoorCheck.configuration.parent_mailer.constantize
    def code_and_link(challenge, to:)
      @code = challenge.code
      @link = email_link_url(token: challenge.token)
      mail to: to, subject: "Your sign-in code"
    end

    def confirmation(challenge)
      @link = confirm_email_url(token: challenge.token)
      mail to: challenge.email, subject: "Confirm your email address"
    end

    def email_change_confirmation(challenge)
      @link = confirm_email_change_url(token: challenge.token)
      mail to: challenge.email, subject: "Confirm your new email address"
    end
  end
end

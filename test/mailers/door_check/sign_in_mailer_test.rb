require "test_helper"

module DoorCheck
  class SignInMailerTest < ActionMailer::TestCase
    setup { @challenge = Challenge.issue(User.create!(email: "ada@example.com")) }

    test "the sign-in email holds the six-digit code" do
      mail = SignInMailer.code_and_link(@challenge, to: "ada@example.com")

      assert_match @challenge.code, mail.text_part.body.to_s
    end
  end
end

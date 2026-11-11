require "test_helper"

module DoorCheck
  class SignInMailerTest < ActionMailer::TestCase
    setup { @challenge = Challenge.issue(User.create!(email: "ada@example.com")) }

    test "the sign-in email holds the six-digit code" do
      mail = SignInMailer.code_and_link(@challenge, to: "ada@example.com")

      assert_match @challenge.code, mail.text_part.body.to_s
    end

    test "the sign-in email holds a link that signs the person in" do
      mail = SignInMailer.code_and_link(@challenge, to: "ada@example.com")

      assert_match "/door_check/email_link/#{@challenge.token}", mail.text_part.body.to_s
    end

    test "the sign-in email is sent with the host app's own mail settings" do
      mail = SignInMailer.code_and_link(@challenge, to: "ada@example.com")

      assert_equal [ "hello@dummy-app.example" ], mail.from
    end
  end
end

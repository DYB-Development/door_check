require "test_helper"

class EmailConfirmationTest < ActionDispatch::IntegrationTest
  setup { @user = User.create!(email: "ada@example.com") }

  test "opening the confirmation link marks the person's address as confirmed" do
    challenge = DoorCheck::Challenge.issue_confirmation(@user, "ada@example.com")

    get "/door_check/confirm_email/#{challenge.token}"

    assert DoorCheck::EmailConfirmation.confirmed?(@user, "ada@example.com")
  end

  test "opening the confirmation link shows a page saying the address is confirmed" do
    challenge = DoorCheck::Challenge.issue_confirmation(@user, "ada@example.com")

    get "/door_check/confirm_email/#{challenge.token}"

    assert_select "[role=alert]", text: /Your email address is confirmed/
  end

  test "opening the confirmation link does not sign anyone in" do
    challenge = DoorCheck::Challenge.issue_confirmation(@user, "ada@example.com")

    get "/door_check/confirm_email/#{challenge.token}"

    assert_nil session[:user_id]
  end

  test "a confirmation link opened a second time says it no longer works" do
    challenge = DoorCheck::Challenge.issue_confirmation(@user, "ada@example.com")
    get "/door_check/confirm_email/#{challenge.token}"

    get "/door_check/confirm_email/#{challenge.token}"

    assert_select "[role=alert]", text: /no longer works/
  end

  test "a confirmation link opened after a day says it no longer works" do
    challenge = DoorCheck::Challenge.issue_confirmation(@user, "ada@example.com")

    travel 25.hours do
      get "/door_check/confirm_email/#{challenge.token}"
    end

    assert_select "[role=alert]", text: /no longer works/
  end

  test "a signed-in person awaiting confirmation who asks for it again is emailed a new confirmation link" do
    DoorCheck::EmailConfirmation.for(@user).update!(email: "ada@example.com")
    post "/sign_in", params: { user_id: @user.id, method_name: "password" }

    post "/door_check/email_confirmation"

    assert_match %r{/door_check/confirm_email/}, ActionMailer::Base.deliveries.last&.text_part&.body.to_s
  end

  test "the earlier confirmation link still confirms the address after the email is sent again" do
    earlier = DoorCheck::Challenge.issue_confirmation(@user, "ada@example.com")
    DoorCheck::EmailConfirmation.for(@user).update!(email: "ada@example.com")
    post "/sign_in", params: { user_id: @user.id, method_name: "password" }
    post "/door_check/email_confirmation"

    get "/door_check/confirm_email/#{earlier.token}"

    assert DoorCheck::EmailConfirmation.confirmed?(@user, "ada@example.com")
  end

  test "a used confirmation link's page has a button to send a new confirmation email" do
    challenge = DoorCheck::Challenge.issue_confirmation(@user, "ada@example.com")
    get "/door_check/confirm_email/#{challenge.token}"

    get "/door_check/confirm_email/#{challenge.token}"

    assert_select "form[action='/door_check/email_confirmation?token=#{challenge.token}'] button", text: "Send a new confirmation email"
  end

  test "a signed-out person who asks for a new email from a used confirmation link is sent one at that link's address" do
    challenge = DoorCheck::Challenge.issue_confirmation(@user, "ada@example.com")
    get "/door_check/confirm_email/#{challenge.token}"

    post "/door_check/email_confirmation", params: { token: challenge.token }

    assert_equal [ "ada@example.com" ], ActionMailer::Base.deliveries.last&.to
  end
end

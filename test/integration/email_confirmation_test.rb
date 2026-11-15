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
end

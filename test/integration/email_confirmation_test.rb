require "test_helper"

class EmailConfirmationTest < ActionDispatch::IntegrationTest
  setup { @user = User.create!(email: "ada@example.com") }

  test "opening the confirmation link marks the person's address as confirmed" do
    challenge = DoorCheck::Challenge.issue_confirmation(@user, "ada@example.com")

    get "/door_check/confirm_email/#{challenge.token}"

    assert DoorCheck::EmailConfirmation.confirmed?(@user, "ada@example.com")
  end
end

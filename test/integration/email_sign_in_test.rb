require "test_helper"

class EmailSignInTest < ActionDispatch::IntegrationTest
  setup { @user = User.create!(email: "ada@example.com") }

  test "a person who enters their email address receives one email" do
    assert_emails 1 do
      post "/door_check/email_sign_in", params: { email: "ada@example.com" }
    end
  end
end

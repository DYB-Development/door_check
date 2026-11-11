require "test_helper"

class AuthenticatorSetupTest < ActionDispatch::IntegrationTest
  setup do
    @user = User.create!(email: "ada@example.com")
    post sign_in_path, params: { user_id: @user.id, method_name: "password" }
  end

  test "setting up an authenticator app shows a QR code to scan" do
    get "/door_check/authenticator/new"

    assert_select "svg"
  end
end

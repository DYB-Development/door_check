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

  test "the setup page asks for the code the app shows" do
    get "/door_check/authenticator/new"

    assert_select "form[action='/door_check/authenticator'] input[name=code]"
  end

  test "a person who types the code their new authenticator app shows has it saved" do
    get "/door_check/authenticator/new"
    secret = session[DoorCheck::AuthenticatorsController::PENDING_SECRET_KEY]

    post "/door_check/authenticator", params: { code: ROTP::TOTP.new(secret).now }

    assert DoorCheck::Credential.exists?(person: @user, method_name: "authenticator_app")
  end
end

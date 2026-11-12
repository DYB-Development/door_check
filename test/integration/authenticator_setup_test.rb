require "test_helper"

class AuthenticatorSetupTest < ActionDispatch::IntegrationTest
  setup do
    @user = User.create!(email: "ada@example.com")
    post sign_in_path, params: { user_id: @user.id, method_name: "password" }
  end

  test "setting up an authenticator app shows a QR code to scan" do
    get "/door_check/authenticator/new"

    assert_select "img[src^='data:image/svg+xml;base64,']"
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

  test "a wrong code is refused and saves nothing" do
    get "/door_check/authenticator/new"

    post "/door_check/authenticator", params: { code: "000000" }

    assert_select "div", text: /That code is not right/
  end

  test "a password sign-in of a person who already has a second step is asked for it before adding another" do
    @user.update!(authenticator_code: "123456")

    get "/door_check/authenticator/new"

    assert_redirected_to "/door_check/second_step/new"
  end

  test "a person who sets up an authenticator app when an account asks enters that account" do
    account = Account.create!(name: "Acme")
    DoorCheck::AccountRule.create!(account: account, second_step_required: true)
    post switch_account_path(account)
    get dashboard_path
    get "/door_check/authenticator/new"
    post "/door_check/authenticator", params: { code: ROTP::TOTP.new(session[DoorCheck::AuthenticatorsController::PENDING_SECRET_KEY]).now }

    get "/dashboard"

    assert_response :ok
  end
end

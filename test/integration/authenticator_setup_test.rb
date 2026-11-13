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

  test "the QR code adds the account under the name the host gives the authenticator app" do
    DoorCheck.configuration.authenticator_issuer = "Door Desk"
    get "/door_check/authenticator/new"
    DoorCheck.configuration.authenticator_issuer = nil
    secret = session[DoorCheck::AuthenticatorsController::PENDING_SECRET_KEY]
    uri = ROTP::TOTP.new(secret, issuer: "Door Desk").provisioning_uri("ada@example.com")
    svg = RQRCode::QRCode.new(uri).as_svg(module_size: 4, use_path: true)

    assert_select "img[src=?]", "data:image/svg+xml;base64,#{Base64.strict_encode64(svg)}"
  end

  test "the setup page tells a person to scan the code or type the secret key, then enter the code their app shows" do
    get "/door_check/authenticator/new"

    assert_select "p", text: "Scan the QR code or type the secret key into your authenticator app, then enter the code it shows."
  end

  test "the setup page shows the secret key in groups of four so a person can type it into an authenticator app on the same phone" do
    get "/door_check/authenticator/new"

    assert_select "pre code", text: session[DoorCheck::AuthenticatorsController::PENDING_SECRET_KEY].scan(/.{1,4}/).join(" ")
  end

  test "the setup page copies the secret key when its copy button is tapped" do
    get "/door_check/authenticator/new"

    assert_select "button[data-controller=clipboard][data-clipboard-text=?]", session[DoorCheck::AuthenticatorsController::PENDING_SECRET_KEY]
  end

  test "loading the setup page again shows the same secret key" do
    get "/door_check/authenticator/new"
    first_key = session[DoorCheck::AuthenticatorsController::PENDING_SECRET_KEY]

    get "/door_check/authenticator/new"

    assert_equal first_key, session[DoorCheck::AuthenticatorsController::PENDING_SECRET_KEY]
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

  test "a wrong code saves no authenticator app" do
    get "/door_check/authenticator/new"

    post "/door_check/authenticator", params: { code: "000000" }

    assert_not DoorCheck::Credential.exists?(person: @user, method_name: "authenticator_app")
  end

  test "sending a code after the pending key was lost starts setup again" do
    post "/door_check/authenticator", params: { code: "000000" }

    assert_redirected_to "/door_check/authenticator/new"
  end

  test "a person whose pending key was lost is told setup started again with a new key" do
    post "/door_check/authenticator", params: { code: "000000" }
    follow_redirect!

    assert_select "div", text: /Setup started again/
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

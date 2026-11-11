require "test_helper"
require "webauthn/fake_client"

class PasskeySetupTest < ActionDispatch::IntegrationTest
  setup do
    @user = User.create!(email: "ada@example.com")
    @client = WebAuthn::FakeClient.new("http://www.example.com")
    post sign_in_path, params: { user_id: @user.id, method_name: "password" }
  end

  test "a person who adds a passkey has it saved under the name they gave" do
    get "/door_check/passkeys/new"

    post "/door_check/passkeys", params: { name: "Work laptop", credential: @client.create(challenge: session[:door_check_passkey_challenge]).to_json }

    assert DoorCheck::Credential.exists?(person: @user, method_name: "passkey", name: "Work laptop")
  end

  test "a passkey answer made for a different challenge is refused" do
    get "/door_check/passkeys/new"

    post "/door_check/passkeys", params: { name: "Work laptop", credential: @client.create.to_json }

    assert_select "div", text: /could not be added/
  end

  test "a password sign-in of a person who already has a second step is asked for it before adding a passkey" do
    @user.update!(authenticator_code: "123456")

    get "/door_check/passkeys/new"

    assert_redirected_to "/door_check/second_step/new"
  end
end

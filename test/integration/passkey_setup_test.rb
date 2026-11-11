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
end

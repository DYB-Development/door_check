require "test_helper"
require "webauthn/fake_client"

class PasskeySignInTest < ActionDispatch::IntegrationTest
  setup do
    @user = User.create!(email: "ada@example.com")
    @client = WebAuthn::FakeClient.new("http://www.example.com")
    add_passkey
    reset!
  end

  test "a person signs in with a passkey that checked their fingerprint, face or PIN" do
    get "/door_check/passkey_sign_in/new"
    post "/door_check/passkey_sign_in", params: { credential: @client.get(challenge: session[:door_check_passkey_challenge], user_verified: true).to_json }

    get "/proofs"

    assert_equal [ "passkey" ], response.parsed_body
  end

  private

  def add_passkey
    post sign_in_path, params: { user_id: @user.id, method_name: "password" }
    get "/door_check/passkeys/new"
    post "/door_check/passkeys", params: { name: "Phone", credential: @client.create(challenge: session[:door_check_passkey_challenge], user_verified: true).to_json }
  end
end

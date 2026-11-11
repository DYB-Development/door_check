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

  test "a passkey that did not check the person's fingerprint, face or PIN does not sign them in" do
    get "/door_check/passkey_sign_in/new"

    post "/door_check/passkey_sign_in", params: { credential: @client.get(challenge: session[:door_check_passkey_challenge], user_verified: false).to_json }

    assert_select "div", text: /could not sign you in/
  end

  test "signing in with a passkey records when it was last used" do
    get "/door_check/passkey_sign_in/new"

    post "/door_check/passkey_sign_in", params: { credential: @client.get(challenge: session[:door_check_passkey_challenge], user_verified: true).to_json }

    assert DoorCheck::Credential.find_by(method_name: "passkey").last_used_at
  end

  test "a passkey sign-in enters an account that requires a second step without being asked" do
    account = Account.create!(name: "Acme")
    DoorCheck::AccountRule.create!(account: account, second_step_required: true)
    get "/door_check/passkey_sign_in/new"
    post "/door_check/passkey_sign_in", params: { credential: @client.get(challenge: session[:door_check_passkey_challenge], user_verified: true).to_json }
    post "/accounts/#{account.id}/switch"

    get "/dashboard"

    assert_response :ok
  end

  test "an app that does not offer passkeys does not sign in with one" do
    offered = DoorCheck.configuration.offered_methods
    DoorCheck.configuration.offered_methods = %i[password]

    post "/door_check/passkey_sign_in", params: { credential: "{}" }

    assert_response :not_found
  ensure
    DoorCheck.configuration.offered_methods = offered
  end

  private

  def add_passkey
    post sign_in_path, params: { user_id: @user.id, method_name: "password" }
    get "/door_check/passkeys/new"
    post "/door_check/passkeys", params: { name: "Phone", credential: @client.create(challenge: session[:door_check_passkey_challenge], user_verified: true).to_json }
  end
end

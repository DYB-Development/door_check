require "test_helper"

class SignedInSessionsTest < ActionDispatch::IntegrationTest
  setup { @user = User.create!(email: "ada@example.com") }

  test "a sign-in records the device it came from" do
    post sign_in_path, params: { user_id: @user.id, method_name: "password" }, headers: { "User-Agent" => "Safari on iPhone" }

    assert_equal "Safari on iPhone", DoorCheck::SignedInSession.last.device
  end

  test "using the app records when the session was last used" do
    post sign_in_path, params: { user_id: @user.id, method_name: "password" }
    travel 10.minutes

    get "/proofs"

    assert_in_delta Time.current, DoorCheck::SignedInSession.last.last_used_at, 1.second
  end

  test "a browser whose session was signed out from another device is signed out on its next visit" do
    post sign_in_path, params: { user_id: @user.id, method_name: "password" }
    DoorCheck::SignedInSession.last.update!(signed_out_at: Time.current)

    get "/proofs"

    assert_nil session[:user_id]
  end
end

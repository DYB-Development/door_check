require "test_helper"

class SignedInSessionsTest < ActionDispatch::IntegrationTest
  setup { @user = User.create!(email: "ada@example.com") }

  test "a sign-in records the device it came from" do
    post sign_in_path, params: { user_id: @user.id, method_name: "password" }, headers: { "User-Agent" => "Safari on iPhone" }

    assert_equal "Safari on iPhone", DoorCheck::SignedInSession.last.device
  end
end

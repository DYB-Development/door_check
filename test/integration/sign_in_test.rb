require "test_helper"

class SignInTest < ActionDispatch::IntegrationTest
  setup { @user = User.create!(email: "ada@example.com") }

  test "a sign-in the host app reports is proved by the method it names" do
    post sign_in_path, params: { user_id: @user.id, method_name: "password" }
    get proofs_path

    assert_equal [ "password" ], response.parsed_body
  end
end

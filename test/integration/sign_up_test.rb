require "test_helper"

class SignUpTest < ActionDispatch::IntegrationTest
  test "a visitor opens the sign-up page and is asked for their name" do
    get "/door_check/sign_up/new"

    assert_select "form[action='/door_check/sign_up'] input[name=name]"
  end
end

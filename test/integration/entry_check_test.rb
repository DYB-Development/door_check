require "test_helper"

class EntryCheckTest < ActionDispatch::IntegrationTest
  setup do
    @user = User.create!(email: "ada@example.com", authenticator_code: "123456", backup_codes: "aaaa,bbbb")
    @account = Account.create!(name: "Acme")
  end

  test "a password sign-in entering an account that requires a second step is asked for one" do
    DoorCheck::AccountRule.create!(account: @account, second_step_required: true)
    post sign_in_path, params: { user_id: @user.id, method_name: "password" }
    post switch_account_path(@account)

    get dashboard_path

    assert_redirected_to "/door_check/second_step/new"
  end

  test "the second-step screen asks for a code" do
    post sign_in_path, params: { user_id: @user.id, method_name: "password" }

    get "/door_check/second_step/new"

    assert_select "input[name=code]"
  end

  test "a correct authenticator code proves the second step and returns to the page asked for" do
    DoorCheck::AccountRule.create!(account: @account, second_step_required: true)
    post sign_in_path, params: { user_id: @user.id, method_name: "password" }
    post switch_account_path(@account)
    get dashboard_path

    post "/door_check/second_step", params: { code: "123456" }

    assert_redirected_to "/dashboard"
  end
end

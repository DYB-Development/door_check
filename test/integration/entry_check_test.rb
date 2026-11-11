require "test_helper"

class EntryCheckTest < ActionDispatch::IntegrationTest
  setup do
    @user = User.create!(email: "ada@example.com")
    @account = Account.create!(name: "Acme")
  end

  test "a password sign-in entering an account that requires a second step is asked for one" do
    DoorCheck::AccountRule.create!(account: @account, second_step_required: true)
    post sign_in_path, params: { user_id: @user.id, method_name: "password" }
    post switch_account_path(@account)

    get dashboard_path

    assert_redirected_to "/door_check/second_step/new"
  end
end

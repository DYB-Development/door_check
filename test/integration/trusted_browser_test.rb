require "test_helper"

class TrustedBrowserTest < ActionDispatch::IntegrationTest
  setup do
    @user = User.create!(email: "ada@example.com", authenticator_code: "123456")
    @account = Account.create!(name: "Acme")
    DoorCheck::AccountRule.create!(account: @account, second_step_required: true)
  end

  test "a person who ticks trust this browser while giving a second step has the browser trusted" do
    post sign_in_path, params: { user_id: @user.id, method_name: "password" }

    post "/door_check/second_step", params: { code: "123456", trust_browser: "1" }

    assert DoorCheck::TrustedDevice.exists?(person: @user)
  end

  test "a trusted browser is not asked for a second step on a later sign-in" do
    trust_this_browser
    post sign_in_path, params: { user_id: @user.id, method_name: "password" }
    post switch_account_path(@account)

    get dashboard_path

    assert_response :ok
  end

  private

  def trust_this_browser
    post sign_in_path, params: { user_id: @user.id, method_name: "password" }
    post "/door_check/second_step", params: { code: "123456", trust_browser: "1" }
    delete sign_out_path
  end
end

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

  test "a wrong code is refused and proves nothing" do
    post sign_in_path, params: { user_id: @user.id, method_name: "password" }

    post "/door_check/second_step", params: { code: "000000" }

    assert_select "div", text: /That code is not right/
  end

  test "a person with no second step set up is offered the authenticator app setup" do
    @user.update!(authenticator_code: nil)
    post sign_in_path, params: { user_id: @user.id, method_name: "password" }

    get "/door_check/second_step/new"

    assert_select "a[href='/door_check/authenticator/new']"
  end

  test "a backup code used once is refused the second time" do
    post sign_in_path, params: { user_id: @user.id, method_name: "password" }
    post "/door_check/second_step", params: { code: "aaaa" }

    post "/door_check/second_step", params: { code: "aaaa" }

    assert_select "div", text: /That code is not right/
  end

  test "a sign-in that already gave a second step enters the account without being asked" do
    DoorCheck::AccountRule.create!(account: @account, second_step_required: true)
    post sign_in_path, params: { user_id: @user.id, method_name: "authenticator_app" }
    post switch_account_path(@account)

    get dashboard_path

    assert_response :ok
  end

  test "moving from an account with no rule into one with it asks at that moment" do
    relaxed = Account.create!(name: "Relaxed")
    DoorCheck::AccountRule.create!(account: @account, second_step_required: true)
    post sign_in_path, params: { user_id: @user.id, method_name: "password" }
    post switch_account_path(relaxed)
    get dashboard_path
    post switch_account_path(@account)

    get dashboard_path

    assert_redirected_to "/door_check/second_step/new"
  end

  test "a password sign-in entering an account that accepts only an authenticator app is asked for it" do
    DoorCheck::AccountRule.create!(account: @account, accepted_methods: %w[authenticator_app])
    post sign_in_path, params: { user_id: @user.id, method_name: "password" }
    post switch_account_path(@account)

    get dashboard_path

    assert_redirected_to "/door_check/second_step/new"
  end

  test "an account with no rule asks for nothing beyond the sign-in" do
    post sign_in_path, params: { user_id: @user.id, method_name: "password" }
    post switch_account_path(@account)

    get dashboard_path

    assert_response :ok
  end

  test "a code from an authenticator app set up in the gem proves the second step" do
    @user.update!(authenticator_code: nil)
    credential = DoorCheck::Credential.create!(person: @user, method_name: "authenticator_app", secret: ROTP::Base32.random)
    DoorCheck::AccountRule.create!(account: @account, second_step_required: true)
    post sign_in_path, params: { user_id: @user.id, method_name: "password" }
    post switch_account_path(@account)
    get dashboard_path

    post "/door_check/second_step", params: { code: ROTP::TOTP.new(credential.secret).now }

    assert_redirected_to "/dashboard"
  end

  test "a person who requires a second step of their own is asked for it with no account involved" do
    DoorCheck::PersonRule.create!(person: @user, second_step_required: true)
    post sign_in_path, params: { user_id: @user.id, method_name: "password" }

    get dashboard_path

    assert_redirected_to "/door_check/second_step/new"
  end

  test "an account that does not accept an authenticator app is not offered its setup" do
    @user.update!(authenticator_code: nil)
    DoorCheck::AccountRule.create!(account: @account, accepted_methods: %w[password], second_step_required: true)
    post sign_in_path, params: { user_id: @user.id, method_name: "password" }
    post switch_account_path(@account)

    get "/door_check/second_step/new"

    assert_select "a[href='/door_check/authenticator/new']", count: 0
  end

  test "a backup code made in the gem proves the second step" do
    @user.update!(authenticator_code: nil, backup_codes: nil)
    codes = DoorCheck::BackupCodes.create_for(@user)
    DoorCheck::AccountRule.create!(account: @account, second_step_required: true)
    post sign_in_path, params: { user_id: @user.id, method_name: "password" }
    post switch_account_path(@account)
    get dashboard_path

    post "/door_check/second_step", params: { code: codes.first }

    assert_redirected_to "/dashboard"
  end
end

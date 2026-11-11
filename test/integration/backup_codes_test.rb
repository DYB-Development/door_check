require "test_helper"

class BackupCodesTest < ActionDispatch::IntegrationTest
  setup do
    @user = User.create!(email: "ada@example.com")
    post sign_in_path, params: { user_id: @user.id, method_name: "password" }
  end

  test "making a set of backup codes shows all ten" do
    post "/door_check/backup_codes"

    assert_select "code", count: 10
  end

  test "a password sign-in of a person who already has a second step is asked for it before making codes" do
    @user.update!(authenticator_code: "123456")

    post "/door_check/backup_codes"

    assert_redirected_to "/door_check/second_step/new"
  end

  test "an app that does not offer backup codes makes none" do
    offered = DoorCheck.configuration.offered_methods
    DoorCheck.configuration.offered_methods = %i[password]

    post "/door_check/backup_codes"

    assert_response :not_found
  ensure
    DoorCheck.configuration.offered_methods = offered
  end
end

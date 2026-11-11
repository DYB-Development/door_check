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
end

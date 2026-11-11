require "test_helper"

module DoorCheck
  class BackupCodesTest < ActiveSupport::TestCase
    setup { @user = User.create!(email: "ada@example.com") }

    test "a new set holds ten codes" do
      assert_equal 10, BackupCodes.create_for(@user).size
    end

    test "a code from the set is accepted" do
      codes = BackupCodes.create_for(@user)

      assert BackupCodes.use(@user, codes.first)
    end
  end
end

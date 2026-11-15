require "test_helper"

module DoorCheck
  class EmailConfirmationTest < ActiveSupport::TestCase
    setup { @user = User.create!(email: "ada@example.com") }

    test "a person whose address was confirmed reads as confirmed for that address" do
      EmailConfirmation.for(@user).confirm("ada@example.com")

      assert EmailConfirmation.confirmed?(@user, "ada@example.com")
    end
  end
end

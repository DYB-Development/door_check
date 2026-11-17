require "test_helper"

module DoorCheck
  class EmailConfirmationTest < ActiveSupport::TestCase
    setup { @user = User.create!(email: "ada@example.com") }

    test "a person whose address was confirmed reads as confirmed for that address" do
      EmailConfirmation.for(@user).confirm("ada@example.com")

      assert EmailConfirmation.confirmed?(@user, "ada@example.com")
    end

    test "a person whose address the host has since changed reads as not confirmed" do
      EmailConfirmation.for(@user).confirm("ada@example.com")

      assert_not EmailConfirmation.confirmed?(@user, "ada@newmail.example")
    end

    test "a confirmed address the host writes in different letter case reads as confirmed" do
      EmailConfirmation.for(@user).confirm("Ada@Example.com")

      assert EmailConfirmation.confirmed?(@user, "ada@example.com")
    end

    test "a person sent a confirmation they have not used is awaiting confirmation" do
      EmailConfirmation.for(@user).update!(email: "ada@example.com")

      assert EmailConfirmation.for(@user).awaiting?
    end

    test "a person whose host email is blank is not awaiting confirmation" do
      EmailConfirmation.for(@user).update!(email: "ada@example.com")
      @user.update!(email: "")

      assert_not EmailConfirmation.for(@user).awaiting?
    end
  end
end

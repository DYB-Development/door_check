require "test_helper"

module DoorCheck
  class RequestEmailChangeTest < ActiveSupport::TestCase
    include ActionMailer::TestHelper

    setup do
      ActionMailer::Base.deliveries.clear
      @user = User.create!(email: "ada@example.com")
    end

    test "a request with a new address is accepted" do
      result = RequestEmailChange.new(person: @user, account: nil, values: { email: "new@example.com" }).call

      assert result.ok?
    end

    test "an accepted request emails the new address" do
      RequestEmailChange.new(person: @user, account: nil, values: { email: "new@example.com" }).call

      assert_includes ActionMailer::Base.deliveries.map(&:to), [ "new@example.com" ]
    end

    test "an accepted request emails the person's current address a notice of the change" do
      RequestEmailChange.new(person: @user, account: nil, values: { email: "new@example.com" }).call

      assert_includes ActionMailer::Base.deliveries.map(&:to), [ "ada@example.com" ]
    end

    test "a request for a person with no current address sends only the confirmation" do
      assert_emails 1 do
        RequestEmailChange.new(person: User.create!(email: nil), account: nil, values: { email: "new@example.com" }).call
      end
    end

    test "an accepted request leaves the confirmed check true for the old address" do
      EmailConfirmation.for(@user).confirm("ada@example.com")

      RequestEmailChange.new(person: @user, account: nil, values: { email: "new@example.com" }).call

      assert EmailConfirmation.confirmed?(@user, "ada@example.com")
    end

    test "a request with a blank address is refused with a message" do
      result = RequestEmailChange.new(person: @user, account: nil, values: { email: " " }).call

      assert_equal "Enter the new email address.", result.message
    end

    test "a request with a blank address sends no email" do
      assert_no_emails do
        RequestEmailChange.new(person: @user, account: nil, values: { email: "" }).call
      end
    end
  end
end

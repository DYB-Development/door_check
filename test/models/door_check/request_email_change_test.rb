require "test_helper"

module DoorCheck
  class RequestEmailChangeTest < ActiveSupport::TestCase
    include ActionMailer::TestHelper

    setup { @user = User.create!(email: "ada@example.com") }

    test "a request with a new address is accepted" do
      result = RequestEmailChange.new(person: @user, account: nil, values: { email: "new@example.com" }).call

      assert result.ok?
    end

    test "an accepted request emails the new address" do
      RequestEmailChange.new(person: @user, account: nil, values: { email: "new@example.com" }).call

      assert_equal [ "new@example.com" ], ActionMailer::Base.deliveries.last&.to
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

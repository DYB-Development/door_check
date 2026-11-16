require "test_helper"

module DoorCheck
  class RequestEmailChangeTest < ActiveSupport::TestCase
    setup { @user = User.create!(email: "ada@example.com") }

    test "a request with a new address is accepted" do
      result = RequestEmailChange.new(person: @user, account: nil, values: { email: "new@example.com" }).call

      assert result.ok?
    end

    test "an accepted request emails the new address" do
      RequestEmailChange.new(person: @user, account: nil, values: { email: "new@example.com" }).call

      assert_equal [ "new@example.com" ], ActionMailer::Base.deliveries.last&.to
    end
  end
end

require "test_helper"

class DeviceApprovalTest < ActionDispatch::IntegrationTest
  setup { @user = User.create!(email: "ada@example.com") }

  test "a person asking for approval sees a number to match on their other device" do
    post "/door_check/approval_request", params: { email: "ada@example.com" }
    follow_redirect!

    assert_select "strong", text: DoorCheck::Challenge.last.number
  end
end

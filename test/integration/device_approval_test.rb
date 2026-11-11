require "test_helper"

class DeviceApprovalTest < ActionDispatch::IntegrationTest
  setup { @user = User.create!(email: "ada@example.com") }

  test "a person asking for approval sees a number to match on their other device" do
    post "/door_check/approval_request", params: { email: "ada@example.com" }
    follow_redirect!

    assert_select "strong", text: DoorCheck::Challenge.last.number
  end

  test "the person's other signed-in device shows the request with its number" do
    signed_in = signed_in_device
    post "/door_check/approval_request", params: { email: "ada@example.com" }

    signed_in.get "/door_check/approvals"

    signed_in.assert_select "strong", text: DoorCheck::Challenge.last.number
  end

  test "the request names the device that is asking" do
    signed_in = signed_in_device
    post "/door_check/approval_request", params: { email: "ada@example.com" }, headers: { "User-Agent" => "Chrome on Windows" }

    signed_in.get "/door_check/approvals"

    signed_in.assert_select "p", text: /Chrome on Windows/
  end

  private

  def signed_in_device
    open_session.tap { |device| device.post sign_in_path, params: { user_id: @user.id, method_name: "password" } }
  end
end

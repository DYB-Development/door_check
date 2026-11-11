require "test_helper"
require "turbo/broadcastable/test_helper"

class DeviceApprovalTest < ActionDispatch::IntegrationTest
  include Turbo::Broadcastable::TestHelper

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

  test "the request shows where the asking device is, from the host app's lookup" do
    DoorCheck.configuration.locate_ip = ->(_address) { "Toronto, Canada" }
    signed_in = signed_in_device
    post "/door_check/approval_request", params: { email: "ada@example.com" }

    signed_in.get "/door_check/approvals"

    signed_in.assert_select "p", text: /Toronto, Canada/
  ensure
    DoorCheck.configuration.locate_ip = nil
  end

  test "without a lookup the request shows the asking device's network address" do
    signed_in = signed_in_device
    post "/door_check/approval_request", params: { email: "ada@example.com" }, headers: { "REMOTE_ADDR" => "203.0.113.7" }

    signed_in.get "/door_check/approvals"

    signed_in.assert_select "p", text: /203\.0\.113\.7/
  end

  test "a new request refreshes the person's other signed-in devices" do
    assert_turbo_stream_broadcasts [ @user, :door_check_approvals ] do
      post "/door_check/approval_request", params: { email: "ada@example.com" }
    end
  end

  test "the request list listens for new requests" do
    signed_in = signed_in_device

    signed_in.get "/door_check/approvals"

    signed_in.assert_select "turbo-cable-stream-source"
  end

  test "approving the request on another device signs in the screen that asked" do
    signed_in = signed_in_device
    post "/door_check/approval_request", params: { email: "ada@example.com" }
    signed_in.post "/door_check/approvals/#{DoorCheck::Challenge.last.id}/approve"

    get "/door_check/approval_request"
    get "/proofs"

    assert_equal [ "device_approval" ], response.parsed_body
  end

  private

  def signed_in_device
    open_session.tap { |device| device.post sign_in_path, params: { user_id: @user.id, method_name: "password" } }
  end
end

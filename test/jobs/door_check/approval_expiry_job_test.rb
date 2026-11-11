require "test_helper"
require "turbo/broadcastable/test_helper"

module DoorCheck
  class ApprovalExpiryJobTest < ActiveJob::TestCase
    include Turbo::Broadcastable::TestHelper

    test "an expired request refreshes the screen that asked" do
      challenge = Challenge.request_approval(User.create!(email: "ada@example.com"), device: "Firefox", ip_address: "203.0.113.7")

      assert_turbo_stream_broadcasts challenge do
        ApprovalExpiryJob.perform_now(challenge)
      end
    end
  end
end

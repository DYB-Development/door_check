require "test_helper"

module DoorCheck
  class RemoveTrustedBrowserTest < ActiveSupport::TestCase
    setup { @user = User.create!(email: "ada@example.com") }

    test "a person removes a browser they trusted" do
      TrustedDevice.trust(@user, device: "Safari on iPhone")
      trusted = TrustedDevice.last

      RemoveTrustedBrowser.new(person: @user, account: nil, values: { trusted_device_id: trusted.id.to_s }).call

      assert_not TrustedDevice.exists?(trusted.id)
    end

    test "a person cannot remove another person's trusted browser" do
      TrustedDevice.trust(User.create!(email: "grace@example.com"), device: "Firefox")
      trusted = TrustedDevice.last

      RemoveTrustedBrowser.new(person: @user, account: nil, values: { trusted_device_id: trusted.id.to_s }).call

      assert TrustedDevice.exists?(trusted.id)
    end
  end
end

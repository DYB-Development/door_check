require "test_helper"

module DoorCheck
  class TrustedDeviceTest < ActiveSupport::TestCase
    setup { @user = User.create!(email: "ada@example.com") }

    test "a browser the person trusted is recognised by its token" do
      token = TrustedDevice.trust(@user, device: "Safari on iPhone")

      assert TrustedDevice.recognise(@user, token)
    end
  end
end

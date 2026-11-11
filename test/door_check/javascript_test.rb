require "test_helper"

class DoorCheck::JavascriptTest < ActiveSupport::TestCase
  test "the host app can serve the gem's passkey controller" do
    assert Rails.application.assets.load_path.find("door_check/passkey_controller.js")
  end
end

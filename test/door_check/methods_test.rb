require "test_helper"
require "door_check/methods"

class DoorCheck::MethodsTest < ActiveSupport::TestCase
  test "it knows the twelve methods by name" do
    assert_equal %i[
      password email_code email_link device_approval authenticator_app sms_code
      passkey backup_codes trusted_device google apple sso
    ], DoorCheck::Methods.names
  end
end

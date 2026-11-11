require "test_helper"
require "door_check/configuration"

class DoorCheck::ConfigurationTest < ActiveSupport::TestCase
  test "an app lists the methods it offers" do
    configuration = DoorCheck::Configuration.new
    configuration.offered_methods = %i[password authenticator_app]

    assert_equal %i[password authenticator_app], configuration.offered_methods
  end
end

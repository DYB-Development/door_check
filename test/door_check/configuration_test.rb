require "test_helper"
require "door_check/configuration"

class DoorCheck::ConfigurationTest < ActiveSupport::TestCase
  test "an app lists the methods it offers" do
    configuration = DoorCheck::Configuration.new
    configuration.offered_methods = %i[password authenticator_app]

    assert_equal %i[password authenticator_app], configuration.offered_methods
  end

  test "listing a method the gem does not know is refused with its name" do
    error = assert_raises(DoorCheck::UnknownMethod) do
      DoorCheck::Configuration.new.offered_methods = %i[password carrier_pigeon]
    end

    assert_includes error.message, "carrier_pigeon"
  end

  test "door_check pages load the host's application stylesheet unless the host names another" do
    assert_equal "application", DoorCheck::Configuration.new.stylesheet
  end
end

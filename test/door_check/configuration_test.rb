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

  test "door_check pages use the host's application stylesheet unless the host names another" do
    assert_equal "application", DoorCheck::Configuration.new.stylesheet
  end

  test "door_check pages render no host head partial unless the host names one" do
    assert_nil DoorCheck::Configuration.new.head_partial
  end

  test "the authenticator app shows the host application's name unless the host names another" do
    assert_equal Rails.application.class.module_parent_name, DoorCheck::Configuration.new.authenticator_issuer
  end
end

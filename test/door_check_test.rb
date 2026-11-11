require "test_helper"

class DoorCheckTest < ActiveSupport::TestCase
  test "it has a version number" do
    assert DoorCheck::VERSION
  end

  test "an app configures the gem in one block" do
    previous = DoorCheck.configuration.offered_methods
    DoorCheck.configure { |config| config.offered_methods = %i[passkey] }

    assert_equal %i[passkey], DoorCheck.configuration.offered_methods
  ensure
    DoorCheck.configuration.offered_methods = previous
  end
end

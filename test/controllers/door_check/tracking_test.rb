require "test_helper"

module DoorCheck
  class TrackingTest < ActiveSupport::TestCase
    class Host
      include DoorCheck::Tracking

      def current_team = :the_team
    end

    setup { @previous = DoorCheck.configuration.account_method }
    teardown { DoorCheck.configuration.account_method = @previous }

    test "the account is the one the app's own method returns" do
      DoorCheck.configuration.account_method = :current_team

      assert_equal :the_team, Host.new.door_check_account
    end

    test "an app with no accounts leaves the account unset" do
      DoorCheck.configuration.account_method = nil

      assert_nil Host.new.door_check_account
    end
  end
end

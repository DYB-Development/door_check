require "test_helper"

module DoorCheck
  class SignedInSessionTest < ActiveSupport::TestCase
    test "it records the method that proved the person and when" do
      session = SignedInSession.create!(person: User.create!(email: "ada@example.com"))

      travel_to Time.zone.local(2026, 11, 10, 9, 30) do
        session.prove!(:password)
      end

      assert_equal [ [ :password, Time.zone.local(2026, 11, 10, 9, 30) ] ], session.proved_by
    end
  end
end

require "test_helper"

module DoorCheck
  class PersonRuleTest < ActiveSupport::TestCase
    test "a person requiring a second step of their own is not met by a password alone" do
      user = User.create!(email: "ada@example.com")
      PersonRule.create!(person: user, second_step_required: true)

      assert_not PersonRule.for(user).met_by?(%i[password])
    end
  end
end

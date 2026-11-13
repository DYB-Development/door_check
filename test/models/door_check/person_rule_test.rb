require "test_helper"

module DoorCheck
  class PersonRuleTest < ActiveSupport::TestCase
    test "a person requiring a second step of their own is not met by a password alone" do
      user = User.create!(email: "ada@example.com")
      PersonRule.create!(person: user, second_step_required: true)

      assert_not PersonRule.for(user).met_by?(%i[password])
    end

    test "a person's own second step is not in force in an account that does not let members choose" do
      user = User.create!(email: "ada@example.com")
      account = Account.create!(name: "Acme")
      PersonRule.create!(person: user, second_step_required: true)
      AccountRule.create!(account: account, members_choose_second_step: false)

      assert PersonRule.for(user).met_by?(%i[password], account: account)
    end

    test "a person's own second step is not in force in an app that turns the choice off" do
      user = User.create!(email: "ada@example.com")
      PersonRule.create!(person: user, second_step_required: true)
      DoorCheck.configuration.people_choose_second_step = false

      assert PersonRule.for(user).met_by?(%i[password])
    ensure
      DoorCheck.configuration.people_choose_second_step = true
    end
  end
end

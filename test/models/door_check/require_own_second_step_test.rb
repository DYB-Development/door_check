require "test_helper"

module DoorCheck
  class RequireOwnSecondStepTest < ActiveSupport::TestCase
    test "a person turns on a second step for all their own sign-ins" do
      user = User.create!(email: "ada@example.com")

      RequireOwnSecondStep.new(person: user, account: nil, values: { second_step_required: "1" }).call

      assert PersonRule.for(user).second_step_required
    end

    test "saving the choice in an app that turns the choice off is refused with the app as the one who decides" do
      user = User.create!(email: "ada@example.com")
      DoorCheck.configuration.people_choose_second_step = false

      result = RequireOwnSecondStep.new(person: user, account: nil, values: { second_step_required: "1" }).call

      assert_equal "This app decides when you are asked for a second step.", result.message
    ensure
      DoorCheck.configuration.people_choose_second_step = true
    end

    test "saving the choice in an account that does not let members choose is refused with the account as the one who decides" do
      user = User.create!(email: "ada@example.com")
      account = Account.create!(name: "Acme")
      AccountRule.create!(account: account, members_choose_second_step: false)

      result = RequireOwnSecondStep.new(person: user, account: account, values: { second_step_required: "1" }).call

      assert_equal "Your account decides whether you are asked for a second step.", result.message
    end
  end
end

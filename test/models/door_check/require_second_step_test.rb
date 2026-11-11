require "test_helper"

module DoorCheck
  class RequireSecondStepTest < ActiveSupport::TestCase
    test "saving the section turns the rule on for the account" do
      account = Account.create!(name: "Acme")

      RequireSecondStep.new(person: nil, account: account, values: { second_step_required: "1" }).call

      assert AccountRule.for(account).second_step_required
    end
  end
end

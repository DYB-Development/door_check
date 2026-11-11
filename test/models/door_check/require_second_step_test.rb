require "test_helper"

module DoorCheck
  class RequireSecondStepTest < ActiveSupport::TestCase
    test "saving the section turns the rule on for the account" do
      account = Account.create!(name: "Acme")

      RequireSecondStep.new(person: nil, account: account, values: { second_step_required: "1" }).call

      assert AccountRule.for(account).second_step_required
    end

    test "saving the section keeps the methods the admin picked" do
      account = Account.create!(name: "Acme")

      RequireSecondStep.new(person: nil, account: account, values: { accepted_methods: %w[authenticator_app] }).call

      assert_equal %w[authenticator_app], AccountRule.for(account).accepted_methods
    end
  end
end

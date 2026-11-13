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

    test "saving the section with the members box unticked stops members choosing their own second step" do
      account = Account.create!(name: "Acme")

      RequireSecondStep.new(person: nil, account: account, values: { members_choose_second_step: "0" }).call

      assert_not AccountRule.for(account).members_choose_second_step
    end

    test "saving the section without the members value leaves members choosing their own second step" do
      account = Account.create!(name: "Acme")

      RequireSecondStep.new(person: nil, account: account, values: { second_step_required: "1" }).call

      assert AccountRule.for(account).members_choose_second_step
    end

    test "a method the app does not offer is refused" do
      account = Account.create!(name: "Acme")

      result = RequireSecondStep.new(person: nil, account: account, values: { accepted_methods: %w[sms_code] }).call

      assert_not result.ok?
    end
  end
end

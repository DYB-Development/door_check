require "test_helper"

module DoorCheck
  class AccountRuleTest < ActiveSupport::TestCase
    setup { @account = Account.create!(name: "Acme") }

    test "an account requiring a second step is not met by a password alone" do
      AccountRule.create!(account: @account, second_step_required: true)

      assert_not AccountRule.for(@account).met_by?(%i[password])
    end
  end
end

require "test_helper"

module DoorCheck
  class AccountRuleTest < ActiveSupport::TestCase
    setup { @account = Account.create!(name: "Acme") }

    test "an account requiring a second step is not met by a password alone" do
      AccountRule.create!(account: @account, second_step_required: true)

      assert_not AccountRule.for(@account).met_by?(%i[password])
    end

    test "an account accepting only an authenticator app is not met by a password sign-in" do
      AccountRule.create!(account: @account, accepted_methods: %w[authenticator_app])

      assert_not AccountRule.for(@account).met_by?(%i[password])
    end
  end
end

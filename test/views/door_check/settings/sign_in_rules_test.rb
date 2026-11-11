require "test_helper"

module DoorCheck
  class SignInRulesSectionTest < ActionView::TestCase
    helper KeystoneUiHelper

    test "the section offers a switch to require a second step" do
      render partial: "door_check/settings/sign_in_rules", locals: { account: Account.create!(name: "Acme"), submit_url: "/settings/sign_in_rules" }

      assert_select "input[type=checkbox][name=second_step_required]"
    end

    test "the section offers a choice for each method the app offers" do
      render partial: "door_check/settings/sign_in_rules", locals: { account: Account.create!(name: "Acme"), submit_url: "/settings/sign_in_rules" }

      assert_select "input[type=checkbox][name='accepted_methods[]']", count: DoorCheck.configuration.offered_methods.size
    end
  end
end

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

    test "the members switch is ticked for an account that never saved its rules" do
      render partial: "door_check/settings/sign_in_rules", locals: { account: Account.create!(name: "Acme"), submit_url: "/settings/sign_in_rules" }

      assert_select "input[type=checkbox][name=members_choose_second_step][checked]"
    end

    test "the section shows no members switch when the app turns the choice off" do
      DoorCheck.configuration.people_choose_second_step = false

      render partial: "door_check/settings/sign_in_rules", locals: { account: Account.create!(name: "Acme"), submit_url: "/settings/sign_in_rules" }

      assert_select "input[type=checkbox][name=members_choose_second_step]", count: 0
    ensure
      DoorCheck.configuration.people_choose_second_step = true
    end

    test "the section explains that the app decides when the app turns the choice off" do
      DoorCheck.configuration.people_choose_second_step = false

      render partial: "door_check/settings/sign_in_rules", locals: { account: Account.create!(name: "Acme"), submit_url: "/settings/sign_in_rules" }

      assert_includes rendered, "This app decides when members are asked for a second step."
    ensure
      DoorCheck.configuration.people_choose_second_step = true
    end
  end
end

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

    test "the accepted methods sit in the panel under the title Accepted methods" do
      render_section

      assert_equal DoorCheck.configuration.offered_methods.size, group_titled("Accepted methods").css("input[type=checkbox][name='accepted_methods[]']").size
    end

    test "the account's second step sits in the panel under the title Second step" do
      render_section

      assert_predicate group_titled("Second step").css("input[type=checkbox][name=second_step_required]"), :any?
    end

    test "the members choice sits in the panel under the title Members" do
      render_section

      assert_predicate group_titled("Members").css("input[type=checkbox][name=members_choose_second_step]"), :any?
    end

    private

    def group_titled(title)
      Nokogiri::HTML5(rendered).xpath(
        "//div[contains(@class, 'ks-panel')]//div[div[contains(@class, 'ks-section-header')]//h2[normalize-space() = '#{title}']]"
      )
    end

    def render_section
      render partial: "door_check/settings/sign_in_rules", locals: { account: Account.create!(name: "Acme"), submit_url: "/settings/sign_in_rules" }
    end
  end
end

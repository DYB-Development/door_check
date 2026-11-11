require "test_helper"

module DoorCheck
  class SignInMethodsSectionTest < ActionView::TestCase
    helper KeystoneUiHelper

    setup { @user = User.create!(email: "ada@example.com") }

    test "the section lists each method the person has set up" do
      Credential.create!(person: @user, method_name: "authenticator_app", secret: ROTP::Base32.random)

      render_section

      assert_select "td", text: /Authenticator app/
    end

    test "the section shows when each method was last used" do
      Credential.create!(person: @user, method_name: "authenticator_app", secret: ROTP::Base32.random, last_used_at: Time.zone.parse("2026-11-01 09:00"))

      render_section

      assert_select "td", text: /November 01, 2026/
    end

    test "the section names the person's accounts that accept each method" do
      Account.create!(name: "Acme")
      Credential.create!(person: @user, method_name: "authenticator_app", secret: ROTP::Base32.random)

      render_section

      assert_select "td", text: /Acme/
    end

    test "an account that does not accept a method is left out of its list" do
      strict = Account.create!(name: "Strict")
      AccountRule.create!(account: strict, accepted_methods: %w[password])
      Credential.create!(person: @user, method_name: "authenticator_app", secret: ROTP::Base32.random)

      render_section

      assert_select "td", text: /Strict/, count: 0
    end

    test "the section links to setting up an authenticator app" do
      render_section

      assert_select "a[href='/door_check/authenticator/new']"
    end

    test "each method has a button to remove it" do
      credential = Credential.create!(person: @user, method_name: "authenticator_app", secret: ROTP::Base32.random)

      render_section

      assert_select "form[action='/settings/sign_in_methods/remove?credential_id=#{credential.id}']"
    end

    private

    def render_section
      render partial: "door_check/settings/sign_in_methods",
             locals: { person: @user, account: nil, selection: {}, submit_urls: { own_second_step: "/settings/sign_in_methods/own_second_step", remove: "/settings/sign_in_methods/remove" } }
    end
  end
end

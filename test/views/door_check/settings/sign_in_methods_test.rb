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

    private

    def render_section
      render partial: "door_check/settings/sign_in_methods",
             locals: { person: @user, account: nil, selection: {}, submit_urls: { own_second_step: "/settings/sign_in_methods/own_second_step", remove: "/settings/sign_in_methods/remove" } }
    end
  end
end

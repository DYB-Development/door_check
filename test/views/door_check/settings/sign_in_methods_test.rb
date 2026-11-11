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

    private

    def render_section
      render partial: "door_check/settings/sign_in_methods",
             locals: { person: @user, account: nil, selection: {}, submit_urls: { own_second_step: "/settings/sign_in_methods/own_second_step", remove: "/settings/sign_in_methods/remove" } }
    end
  end
end

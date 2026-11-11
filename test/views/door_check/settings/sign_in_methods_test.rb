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

    test "the section offers a switch to require a second step on every sign-in" do
      render_section

      assert_select "form[action='/settings/sign_in_methods/own_second_step'] input[type=checkbox][name=second_step_required]"
    end

    test "the section has a button to make a new set of backup codes" do
      render_section

      assert_select "form[action='/door_check/backup_codes']"
    end

    test "the section links to adding a passkey or hardware key" do
      render_section

      assert_select "a[href='/door_check/passkeys/new']"
    end

    test "a passkey is listed by the name the person gave it" do
      Credential.create!(person: @user, method_name: "passkey", name: "Work laptop", external_id: "abc", public_key: "key", sign_count: 0)

      render_section

      assert_select "td", text: /Work laptop/
    end

    test "each trusted browser has a button to remove it" do
      TrustedDevice.trust(@user, device: "Safari on iPhone")

      render_section

      assert_select "form[action='/settings/sign_in_methods/remove_trusted_browser?trusted_device_id=#{TrustedDevice.last.id}']"
    end

    test "the section lists each session the person is signed in on with its device" do
      SignedInSession.create!(person: @user, device: "Firefox on Linux", last_used_at: Time.current)

      render_section

      assert_select "td", text: /Firefox on Linux/
    end

    test "each session has a button to sign it out" do
      signed_in_session = SignedInSession.create!(person: @user, device: "Firefox on Linux", last_used_at: Time.current)

      render_section

      assert_select "form[action='/settings/sign_in_methods/sign_out_session?signed_in_session_id=#{signed_in_session.id}']"
    end

    private

    def render_section
      render partial: "door_check/settings/sign_in_methods",
             locals: { person: @user, account: nil, selection: {}, submit_urls: { own_second_step: "/settings/sign_in_methods/own_second_step", remove: "/settings/sign_in_methods/remove",
                                                                   remove_trusted_browser: "/settings/sign_in_methods/remove_trusted_browser",
                                                                   sign_out_session: "/settings/sign_in_methods/sign_out_session" } }
    end
  end
end

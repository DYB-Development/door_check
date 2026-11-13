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

    test "each method's remove action is an option in its row's action menu" do
      credential = Credential.create!(person: @user, method_name: "authenticator_app", secret: ROTP::Base32.random)

      render_section

      assert_select "[data-controller=action-menu] form[action='/settings/sign_in_methods/remove?credential_id=#{credential.id}'] .ks-menu-option"
    end

    test "removing a method asks the person to confirm first" do
      credential = Credential.create!(person: @user, method_name: "authenticator_app", secret: ROTP::Base32.random)

      render_section

      assert_select "form[action='/settings/sign_in_methods/remove?credential_id=#{credential.id}'][data-turbo-confirm='Remove this sign-in method?']"
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

    test "each trusted browser's remove action is an option in its row's action menu" do
      TrustedDevice.trust(@user, device: "Safari on iPhone")

      render_section

      assert_select "form[action='/settings/sign_in_methods/remove_trusted_browser?trusted_device_id=#{TrustedDevice.last.id}'] .ks-menu-option"
    end

    test "the section lists each session the person is signed in on with its device" do
      SignedInSession.create!(person: @user, device: "Firefox on Linux", last_used_at: Time.current)

      render_section

      assert_select "td", text: /Firefox on Linux/
    end

    test "each session's sign-out action is an option in its row's action menu" do
      signed_in_session = SignedInSession.create!(person: @user, device: "Firefox on Linux", last_used_at: Time.current)

      render_section

      assert_select "form[action='/settings/sign_in_methods/sign_out_session?signed_in_session_id=#{signed_in_session.id}'] .ks-menu-option"
    end

    test "signing out a session asks the person to confirm first" do
      signed_in_session = SignedInSession.create!(person: @user, device: "Firefox on Linux", last_used_at: Time.current)

      render_section

      assert_select "form[action='/settings/sign_in_methods/sign_out_session?signed_in_session_id=#{signed_in_session.id}'][data-turbo-confirm='Sign out this session?']"
    end

    test "removing a trusted browser asks the person to confirm first" do
      TrustedDevice.trust(@user, device: "Safari on iPhone")

      render_section

      assert_select "form[action='/settings/sign_in_methods/remove_trusted_browser?trusted_device_id=#{TrustedDevice.last.id}'][data-turbo-confirm='Remove this trusted browser?']"
    end

    test "the section hides the second-step switch when the account does not let members choose" do
      account = Account.create!(name: "Acme")
      AccountRule.create!(account: account, members_choose_second_step: false)

      render_section(account: account)

      assert_select "input[type=checkbox][name=second_step_required]", count: 0
    end

    test "the section shows the second-step switch when the account lets members choose" do
      account = Account.create!(name: "Acme")
      AccountRule.create!(account: account, members_choose_second_step: true)

      render_section(account: account)

      assert_select "label", text: "Ask me for a second step every time I sign in"
    end

    test "the section explains that the account decides when it does not let members choose" do
      account = Account.create!(name: "Acme")
      AccountRule.create!(account: account, members_choose_second_step: false)

      render_section(account: account)

      assert_includes rendered, "Your account decides whether you are asked for a second step."
    end

    test "the section explains that the app decides when the app turns the choice off" do
      DoorCheck.configuration.people_choose_second_step = false

      render_section

      assert_includes rendered, "This app decides when you are asked for a second step."
    ensure
      DoorCheck.configuration.people_choose_second_step = true
    end

    test "the section hides the second-step switch when the app turns the choice off" do
      DoorCheck.configuration.people_choose_second_step = false

      render_section

      assert_select "input[type=checkbox][name=second_step_required]", count: 0
    ensure
      DoorCheck.configuration.people_choose_second_step = true
    end

    test "the section shows the second-step switch when the host renders it with no account" do
      render partial: "door_check/settings/sign_in_methods",
             locals: { person: @user, submit_urls: { own_second_step: "/settings/sign_in_methods/own_second_step" } }

      assert_select "input[type=checkbox][name=second_step_required]"
    end

    test "the person's methods sit in a panel under the title Sign-in methods" do
      Credential.create!(person: @user, method_name: "authenticator_app", secret: ROTP::Base32.random)

      render_section

      assert_includes panel_under("Sign-in methods").css("td").map(&:text).join, "Authenticator app"
    end

    test "the buttons to add a method sit in the panel under the title Sign-in methods" do
      render_section

      assert_predicate panel_under("Sign-in methods").css("a[href='/door_check/authenticator/new']"), :any?
    end

    test "the person's sessions sit in a panel under the title Signed-in sessions" do
      SignedInSession.create!(person: @user, device: "Firefox on Linux", last_used_at: Time.current)

      render_section

      assert_includes panel_under("Signed-in sessions").css("td").map(&:text).join, "Firefox on Linux"
    end

    private

    def panel_under(title)
      Nokogiri::HTML5(rendered).xpath(
        "//div[div[contains(@class, 'ks-section-header')]//h2[normalize-space() = '#{title}']]/div[contains(@class, 'ks-panel')]"
      )
    end

    def render_section(account: nil)
      render partial: "door_check/settings/sign_in_methods",
             locals: { person: @user, account: account, selection: {}, submit_urls: { own_second_step: "/settings/sign_in_methods/own_second_step", remove: "/settings/sign_in_methods/remove",
                                                                   remove_trusted_browser: "/settings/sign_in_methods/remove_trusted_browser",
                                                                   sign_out_session: "/settings/sign_in_methods/sign_out_session" } }
    end
  end
end

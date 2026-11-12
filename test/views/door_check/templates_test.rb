require "test_helper"

module DoorCheck
  class TemplatesTest < ActiveSupport::TestCase
    test "the email sign-in page is built only from keystone_ui components a phone shows" do
      assert_built_from_keystone_ui "email_sign_ins/new"
    end

    test "the email code page is built only from keystone_ui components a phone shows" do
      assert_built_from_keystone_ui "email_codes/new"
    end

    test "the expired email link page is built only from keystone_ui components a phone shows" do
      assert_built_from_keystone_ui "email_links/expired"
    end

    test "the passkey sign-in page is built only from keystone_ui components a phone shows" do
      assert_built_from_keystone_ui "passkey_sign_ins/new"
    end

    test "the passkey setup page is built only from keystone_ui components a phone shows" do
      assert_built_from_keystone_ui "passkeys/new"
    end

    test "the second sign-in step page is built only from keystone_ui components a phone shows" do
      assert_built_from_keystone_ui "second_steps/new"
    end

    test "the authenticator setup page is built only from keystone_ui components a phone shows" do
      assert_built_from_keystone_ui "authenticators/new"
    end

    test "the backup codes page is built only from keystone_ui components a phone shows" do
      assert_built_from_keystone_ui "backup_codes/show"
    end

    test "the approval request page is built only from keystone_ui components a phone shows" do
      assert_built_from_keystone_ui "approval_requests/new"
    end

    test "the approval number page is built only from keystone_ui components a phone shows" do
      assert_built_from_keystone_ui "approval_requests/show"
    end

    test "the approvals page is built only from keystone_ui components a phone shows" do
      assert_built_from_keystone_ui "approvals/index"
    end

    test "a pending sign-in request is built only from keystone_ui components a phone shows" do
      assert_built_from_keystone_ui "approvals/_pending"
    end

    test "the sign-in rules settings section is built only from keystone_ui components a phone shows" do
      assert_built_from_keystone_ui "settings/_sign_in_rules"
    end

    private

    def assert_built_from_keystone_ui(template)
      source = DoorCheck::Engine.root.join("app/views/door_check/#{template}.html.erb").read

      assert_no_match(/<[a-z]|ui_page_header/, source)
    end
  end
end

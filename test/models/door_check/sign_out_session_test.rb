require "test_helper"

module DoorCheck
  class SignOutSessionTest < ActiveSupport::TestCase
    setup { @user = User.create!(email: "ada@example.com") }

    test "a person signs out one of their sessions" do
      signed_in_session = SignedInSession.create!(person: @user)

      SignOutSession.new(person: @user, account: nil, values: { signed_in_session_id: signed_in_session.id.to_s }).call

      assert signed_in_session.reload.signed_out_at
    end

    test "a person cannot sign out another person's session" do
      signed_in_session = SignedInSession.create!(person: User.create!(email: "grace@example.com"))

      SignOutSession.new(person: @user, account: nil, values: { signed_in_session_id: signed_in_session.id.to_s }).call

      assert_nil signed_in_session.reload.signed_out_at
    end
  end
end

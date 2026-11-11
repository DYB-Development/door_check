require "test_helper"

module DoorCheck
  class RemoveMethodTest < ActiveSupport::TestCase
    setup { @user = User.create!(email: "ada@example.com") }

    test "a person removes a method they set up" do
      credential = Credential.create!(person: @user, method_name: "authenticator_app", secret: ROTP::Base32.random)

      RemoveMethod.new(person: @user, account: nil, values: { credential_id: credential.id.to_s }).call

      assert_not Credential.exists?(credential.id)
    end

    test "a person cannot remove another person's method" do
      other = User.create!(email: "grace@example.com")
      credential = Credential.create!(person: other, method_name: "authenticator_app", secret: ROTP::Base32.random)

      RemoveMethod.new(person: @user, account: nil, values: { credential_id: credential.id.to_s }).call

      assert Credential.exists?(credential.id)
    end
  end
end

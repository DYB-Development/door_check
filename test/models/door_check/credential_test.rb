require "test_helper"

module DoorCheck
  class CredentialTest < ActiveSupport::TestCase
    setup { @user = User.create!(email: "ada@example.com") }

    test "an authenticator app accepts the code it currently shows" do
      credential = Credential.create!(person: @user, method_name: "authenticator_app", secret: ROTP::Base32.random)

      assert credential.verify(ROTP::TOTP.new(credential.secret).now)
    end
  end
end

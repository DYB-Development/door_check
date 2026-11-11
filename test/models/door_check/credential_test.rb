require "test_helper"

module DoorCheck
  class CredentialTest < ActiveSupport::TestCase
    setup { @user = User.create!(email: "ada@example.com") }

    test "an authenticator app accepts the code it currently shows" do
      credential = Credential.create!(person: @user, method_name: "authenticator_app", secret: ROTP::Base32.random)

      assert credential.verify(ROTP::TOTP.new(credential.secret).now)
    end

    test "the secret is not stored as it was given" do
      secret = ROTP::Base32.random
      credential = Credential.create!(person: @user, method_name: "authenticator_app", secret: secret)

      assert_not_equal secret, Credential.connection.select_value("SELECT secret FROM door_check_credentials WHERE id = #{credential.id}")
    end
  end
end

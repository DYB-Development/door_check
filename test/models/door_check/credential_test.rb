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

    test "an accepted code records when the authenticator app was last used" do
      credential = Credential.create!(person: @user, method_name: "authenticator_app", secret: ROTP::Base32.random)

      credential.verify(ROTP::TOTP.new(credential.secret).now)

      assert credential.reload.last_used_at
    end

    test "a code already used once is refused the second time" do
      credential = Credential.create!(person: @user, method_name: "authenticator_app", secret: ROTP::Base32.random)
      code = ROTP::TOTP.new(credential.secret).now
      credential.verify(code)

      assert_not credential.verify(code)
    end
  end
end

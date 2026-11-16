require "test_helper"

module DoorCheck
  class ChallengeTest < ActiveSupport::TestCase
    setup { @user = User.create!(email: "ada@example.com") }

    test "the code a challenge was issued with is accepted" do
      challenge = Challenge.issue(@user)

      assert Challenge.find(challenge.id).redeem_code(challenge.code)
    end

    test "a code already used is refused" do
      challenge = Challenge.issue(@user)
      challenge.redeem_code(challenge.code)

      assert_not challenge.reload.redeem_code(challenge.code)
    end

    test "a code is refused once fifteen minutes have passed" do
      challenge = Challenge.issue(@user)

      travel 16.minutes do
        assert_not challenge.redeem_code(challenge.code)
      end
    end

    test "a link's token finds the challenge it was issued with" do
      challenge = Challenge.issue(@user)

      assert_equal challenge, Challenge.redeem_token(challenge.token)
    end

    test "a link already used is refused" do
      challenge = Challenge.issue(@user)
      Challenge.redeem_token(challenge.token)

      assert_nil Challenge.redeem_token(challenge.token)
    end

    test "a link is refused once fifteen minutes have passed" do
      challenge = Challenge.issue(@user)

      travel 16.minutes do
        assert_nil Challenge.redeem_token(challenge.token)
      end
    end

    test "a confirmation link's token is not taken as a sign-in link" do
      challenge = Challenge.issue_confirmation(@user, "ada@example.com")

      assert_nil Challenge.redeem_token(challenge.token)
    end

    test "a sign-in link's token is not taken as a confirmation link" do
      challenge = Challenge.issue(@user)

      assert_nil Challenge.redeem_token(challenge.token, purpose: "confirm")
    end

    test "a confirmation link still works after a sign-in link's fifteen minutes have passed" do
      challenge = Challenge.issue_confirmation(@user, "ada@example.com")

      travel 16.minutes do
        assert_equal challenge, Challenge.redeem_token(challenge.token, purpose: "confirm")
      end
    end

    test "an email change link's token is taken as an email change link" do
      challenge = Challenge.issue_email_change(@user, "new@example.com")

      assert_equal challenge, Challenge.redeem_token(challenge.token, purpose: "change_email")
    end

    test "an email change link already used is refused" do
      challenge = Challenge.issue_email_change(@user, "new@example.com")
      Challenge.redeem_token(challenge.token, purpose: "change_email")

      assert_nil Challenge.redeem_token(challenge.token, purpose: "change_email")
    end

    test "an email change link is refused once 24 hours have passed" do
      challenge = Challenge.issue_email_change(@user, "new@example.com")

      travel 25.hours do
        assert_nil Challenge.redeem_token(challenge.token, purpose: "change_email")
      end
    end

    test "a sign-in challenge holds the address its code was sent to" do
      challenge = Challenge.issue(@user, email: "ada@example.com")

      assert_equal "ada@example.com", challenge.reload.email
    end
  end
end

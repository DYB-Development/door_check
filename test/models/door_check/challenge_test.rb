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
  end
end

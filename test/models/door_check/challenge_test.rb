require "test_helper"

module DoorCheck
  class ChallengeTest < ActiveSupport::TestCase
    setup { @user = User.create!(email: "ada@example.com") }

    test "the code a challenge was issued with is accepted" do
      challenge = Challenge.issue(@user)

      assert Challenge.find(challenge.id).redeem_code(challenge.code)
    end
  end
end

require "test_helper"

class EmailChangeTest < ActionDispatch::IntegrationTest
  setup { @user = User.create!(email: "ada@example.com") }

  test "opening the change link calls the host's setting with the person and the new address" do
    challenge = DoorCheck::Challenge.issue_email_change(@user, "ada@new.example.com")
    received = nil

    with_email_change_confirmed(->(_controller, person, email) { received = [ person, email ]; accepted }) do
      get "/door_check/confirm_email_change/#{challenge.token}"
    end

    assert_equal [ @user, "ada@new.example.com" ], received
  end

  test "opening the change link does not sign anyone in" do
    challenge = DoorCheck::Challenge.issue_email_change(@user, "ada@new.example.com")

    with_email_change_confirmed(->(_controller, _person, _email) { accepted }) do
      get "/door_check/confirm_email_change/#{challenge.token}"
    end

    assert_nil session[:user_id]
  end

  private

  def accepted
    DoorCheck::Result.new(ok: true)
  end

  def with_email_change_confirmed(callable)
    email_change_confirmed = DoorCheck.configuration.email_change_confirmed
    DoorCheck.configuration.email_change_confirmed = callable
    yield
  ensure
    DoorCheck.configuration.email_change_confirmed = email_change_confirmed
  end
end

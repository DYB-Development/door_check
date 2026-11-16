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

  test "a change the host accepts makes the new address confirmed" do
    challenge = DoorCheck::Challenge.issue_email_change(@user, "ada@new.example.com")

    with_email_change_confirmed(->(_controller, _person, _email) { accepted }) do
      get "/door_check/confirm_email_change/#{challenge.token}"
    end

    assert DoorCheck::EmailConfirmation.confirmed?(@user, "ada@new.example.com")
  end

  test "a change the host accepts shows a page saying the new address is confirmed" do
    challenge = DoorCheck::Challenge.issue_email_change(@user, "ada@new.example.com")

    with_email_change_confirmed(->(_controller, _person, _email) { accepted }) do
      get "/door_check/confirm_email_change/#{challenge.token}"
    end

    assert_select "[role=alert]", text: /Your new email address is confirmed/
  end

  test "a change the host refuses leaves the confirmed address as it was" do
    DoorCheck::EmailConfirmation.for(@user).confirm("ada@example.com")
    challenge = DoorCheck::Challenge.issue_email_change(@user, "ada@new.example.com")

    with_email_change_confirmed(->(_controller, _person, _email) { refused }) do
      get "/door_check/confirm_email_change/#{challenge.token}"
    end

    assert DoorCheck::EmailConfirmation.confirmed?(@user, "ada@example.com")
  end

  test "a change the host refuses shows the host's message" do
    challenge = DoorCheck::Challenge.issue_email_change(@user, "ada@new.example.com")

    with_email_change_confirmed(->(_controller, _person, _email) { refused }) do
      get "/door_check/confirm_email_change/#{challenge.token}"
    end

    assert_select "[role=alert]", text: /Another person already uses that email address/
  end

  test "a change whose host setting raises an error shows a general message" do
    challenge = DoorCheck::Challenge.issue_email_change(@user, "ada@new.example.com")

    with_email_change_confirmed(->(_controller, _person, _email) { raise "The host's database is down" }) do
      get "/door_check/confirm_email_change/#{challenge.token}"
    end

    assert_select "[role=alert]", text: /Your email address could not be changed/
  end

  test "an error raised by the host's email change setting is reported to the app's error reporter" do
    challenge = DoorCheck::Challenge.issue_email_change(@user, "ada@new.example.com")

    assert_error_reported(RuntimeError) do
      with_email_change_confirmed(->(_controller, _person, _email) { raise "The host's database is down" }) do
        get "/door_check/confirm_email_change/#{challenge.token}"
      end
    end
  end

  test "a change whose host setting raises an error leaves the confirmed address as it was" do
    DoorCheck::EmailConfirmation.for(@user).confirm("ada@example.com")
    challenge = DoorCheck::Challenge.issue_email_change(@user, "ada@new.example.com")

    with_email_change_confirmed(->(_controller, _person, _email) { raise "The host's database is down" }) do
      get "/door_check/confirm_email_change/#{challenge.token}"
    end

    assert DoorCheck::EmailConfirmation.confirmed?(@user, "ada@example.com")
  end

  test "a change the host refuses without a message shows a general message" do
    challenge = DoorCheck::Challenge.issue_email_change(@user, "ada@new.example.com")

    with_email_change_confirmed(->(_controller, _person, _email) { DoorCheck::Result.new(ok: false) }) do
      get "/door_check/confirm_email_change/#{challenge.token}"
    end

    assert_select "[role=alert]", text: /Your email address could not be changed/
  end

  test "a change link opened a second time says it no longer works and to ask for the change again" do
    challenge = DoorCheck::Challenge.issue_email_change(@user, "ada@new.example.com")

    with_email_change_confirmed(->(_controller, _person, _email) { accepted }) do
      get "/door_check/confirm_email_change/#{challenge.token}"
      get "/door_check/confirm_email_change/#{challenge.token}"
    end

    assert_select "[role=alert]", text: /no longer works.*Ask for the change/
  end

  test "a change link opened after a day says it no longer works" do
    challenge = DoorCheck::Challenge.issue_email_change(@user, "ada@new.example.com")

    travel 25.hours do
      with_email_change_confirmed(->(_controller, _person, _email) { accepted }) do
        get "/door_check/confirm_email_change/#{challenge.token}"
      end
    end

    assert_select "[role=alert]", text: /no longer works/
  end

  test "a person who asks to change their email and opens the emailed link has the host's address changed" do
    DoorCheck::RequestEmailChange.new(person: @user, account: nil, values: { email: "ada@new.example.com" }).call
    link = ActionMailer::Base.deliveries.reverse.find { |mail| mail.to == [ "ada@new.example.com" ] }.text_part.body.to_s[%r{/door_check/confirm_email_change/\S+}]

    get link

    assert_equal "ada@new.example.com", @user.reload.email
  end

  test "opening the This wasn't me link calls the host's cancelled setting with the person and the new address" do
    challenge = DoorCheck::Challenge.issue_email_change_cancel(@user, "ada@new.example.com")
    received = nil

    with_email_change_cancelled(->(_controller, person, email) { received = [ person, email ]; accepted }) do
      get "/door_check/cancel_email_change/#{challenge.token}"
    end

    assert_equal [ @user, "ada@new.example.com" ], received
  end

  test "opening the This wasn't me link shows a page saying the change is cancelled" do
    challenge = DoorCheck::Challenge.issue_email_change_cancel(@user, "ada@new.example.com")

    get "/door_check/cancel_email_change/#{challenge.token}"

    assert_select "[role=alert]", text: /The change to your email address is cancelled/
  end

  test "a cancel whose host setting raises an error still shows the page saying the change is cancelled" do
    challenge = DoorCheck::Challenge.issue_email_change_cancel(@user, "ada@new.example.com")

    with_email_change_cancelled(->(_controller, _person, _email) { raise "The host's database is down" }) do
      get "/door_check/cancel_email_change/#{challenge.token}"
    end

    assert_select "[role=alert]", text: /The change to your email address is cancelled/
  end

  private

  def refused
    DoorCheck::Result.new(ok: false, message: "Another person already uses that email address.")
  end

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

  def with_email_change_cancelled(callable)
    email_change_cancelled = DoorCheck.configuration.email_change_cancelled
    DoorCheck.configuration.email_change_cancelled = callable
    yield
  ensure
    DoorCheck.configuration.email_change_cancelled = email_change_cancelled
  end
end

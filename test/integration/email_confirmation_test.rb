require "test_helper"

class EmailConfirmationTest < ActionDispatch::IntegrationTest
  setup { @user = User.create!(email: "ada@example.com") }

  test "opening the confirmation link marks the person's address as confirmed" do
    challenge = DoorCheck::Challenge.issue_confirmation(@user, "ada@example.com")

    get "/door_check/confirm_email/#{challenge.token}"

    assert DoorCheck::EmailConfirmation.confirmed?(@user, "ada@example.com")
  end

  test "opening the confirmation link shows a page saying the address is confirmed" do
    challenge = DoorCheck::Challenge.issue_confirmation(@user, "ada@example.com")

    get "/door_check/confirm_email/#{challenge.token}"

    assert_select "[role=alert]", text: /Your email address is confirmed/
  end

  test "opening the confirmation link does not sign anyone in" do
    challenge = DoorCheck::Challenge.issue_confirmation(@user, "ada@example.com")

    get "/door_check/confirm_email/#{challenge.token}"

    assert_nil session[:user_id]
  end

  test "a confirmation link opened a second time says it no longer works" do
    challenge = DoorCheck::Challenge.issue_confirmation(@user, "ada@example.com")
    get "/door_check/confirm_email/#{challenge.token}"

    get "/door_check/confirm_email/#{challenge.token}"

    assert_select "[role=alert]", text: /no longer works/
  end

  test "a confirmation link opened after a day says it no longer works" do
    challenge = DoorCheck::Challenge.issue_confirmation(@user, "ada@example.com")

    travel 25.hours do
      get "/door_check/confirm_email/#{challenge.token}"
    end

    assert_select "[role=alert]", text: /no longer works/
  end

  test "a signed-in person awaiting confirmation who asks for it again is emailed a new confirmation link" do
    DoorCheck::EmailConfirmation.for(@user).update!(email: "ada@example.com")
    post "/sign_in", params: { user_id: @user.id, method_name: "password" }

    post "/door_check/email_confirmation"

    assert_match %r{/door_check/confirm_email/}, ActionMailer::Base.deliveries.last&.text_part&.body.to_s
  end

  test "a signed-in person whose host address changed is sent the confirmation email again at the current address" do
    DoorCheck::EmailConfirmation.for(@user).confirm("ada@example.com")
    @user.update!(email: "ada@new.example.com")
    post "/sign_in", params: { user_id: @user.id, method_name: "password" }

    post "/door_check/email_confirmation"

    assert_equal [ "ada@new.example.com" ], ActionMailer::Base.deliveries.last&.to
  end

  test "opening the email sent again to a changed host address confirms that address" do
    DoorCheck::EmailConfirmation.for(@user).confirm("ada@example.com")
    @user.update!(email: "ada@new.example.com")
    post "/sign_in", params: { user_id: @user.id, method_name: "password" }
    post "/door_check/email_confirmation"
    link = ActionMailer::Base.deliveries.last.text_part.body.to_s[%r{/door_check/confirm_email/[^\s]+}]

    get link

    assert DoorCheck::EmailConfirmation.confirmed?(@user, "ada@new.example.com")
  end

  test "the earlier confirmation link still confirms the address after the email is sent again" do
    earlier = DoorCheck::Challenge.issue_confirmation(@user, "ada@example.com")
    DoorCheck::EmailConfirmation.for(@user).update!(email: "ada@example.com")
    post "/sign_in", params: { user_id: @user.id, method_name: "password" }
    post "/door_check/email_confirmation"

    get "/door_check/confirm_email/#{earlier.token}"

    assert DoorCheck::EmailConfirmation.confirmed?(@user, "ada@example.com")
  end

  test "a used confirmation link's page has a button to send a new confirmation email" do
    challenge = DoorCheck::Challenge.issue_confirmation(@user, "ada@example.com")
    get "/door_check/confirm_email/#{challenge.token}"

    get "/door_check/confirm_email/#{challenge.token}"

    assert_select "form[action='/door_check/email_confirmation?token=#{challenge.token}'] button", text: "Send a new confirmation email"
  end

  test "a signed-out person who asks for a new email from a used confirmation link is sent one at that link's address" do
    challenge = DoorCheck::Challenge.issue_confirmation(@user, "ada@example.com")
    get "/door_check/confirm_email/#{challenge.token}"

    post "/door_check/email_confirmation", params: { token: challenge.token }

    assert_equal [ "ada@example.com" ], ActionMailer::Base.deliveries.last&.to
  end

  test "a person who asks for the confirmation email again a sixth time in an hour is told to try again later" do
    DoorCheck::EmailConfirmation.for(@user).update!(email: "ada@example.com")
    post "/sign_in", params: { user_id: @user.id, method_name: "password" }
    5.times { post "/door_check/email_confirmation" }

    post "/door_check/email_confirmation"

    assert_select "[role=alert]", text: /Try again later/
  end

  test "a refused request for the confirmation email sends no email" do
    DoorCheck::EmailConfirmation.for(@user).update!(email: "ada@example.com")
    post "/sign_in", params: { user_id: @user.id, method_name: "password" }
    5.times { post "/door_check/email_confirmation" }

    assert_no_emails { post "/door_check/email_confirmation" }
  end

  test "a signed-out person sent a fifth email from a used link is still sent it" do
    challenge = DoorCheck::Challenge.issue_confirmation(@user, "ada@example.com")
    4.times { post "/door_check/email_confirmation", params: { token: challenge.token } }

    assert_emails(1) { post "/door_check/email_confirmation", params: { token: challenge.token } }
  end

  test "asking for a confirmation email with nobody signed in and no link is answered not found" do
    post "/door_check/email_confirmation"

    assert_response :not_found
  end

  test "a person awaiting confirmation can open every door_check page a confirmed person can" do
    confirmed = User.create!(email: "grace@example.com")
    DoorCheck::EmailConfirmation.for(confirmed).confirm("grace@example.com")
    DoorCheck::EmailConfirmation.for(@user).update!(email: "ada@example.com")

    assert_equal statuses_of_door_check_pages_for(confirmed), statuses_of_door_check_pages_for(@user)
  end

  private

  def statuses_of_door_check_pages_for(user)
    post "/sign_in", params: { user_id: user.id, method_name: "password" }
    %w[/door_check/second_step/new /door_check/authenticator/new /door_check/passkeys/new /door_check/passkey_sign_in/new
       /door_check/email_sign_in/new /door_check/email_code/new /door_check/sign_up/new /door_check/approval_request/new
       /door_check/approvals].map { |path| get(path) }.tap { delete "/sign_out" }
  end
end

require "test_helper"

class EmailSignInTest < ActionDispatch::IntegrationTest
  setup { @user = User.create!(email: "ada@example.com") }

  test "a person who enters their email address receives one email" do
    assert_emails 1 do
      post "/door_check/email_sign_in", params: { email: "ada@example.com" }
    end
  end

  test "asking for a code leads to the screen where it is typed" do
    post "/door_check/email_sign_in", params: { email: "ada@example.com" }

    assert_redirected_to "/door_check/email_code/new"
  end

  test "an address with no person sends nothing" do
    assert_no_emails do
      post "/door_check/email_sign_in", params: { email: "nobody@example.com" }
    end
  end

  test "an address with no person leads to the same screen as a real one" do
    post "/door_check/email_sign_in", params: { email: "nobody@example.com" }

    assert_redirected_to "/door_check/email_code/new"
  end

  test "the sign-in screen asks for an email address" do
    get "/door_check/email_sign_in/new"

    assert_select "form[action='/door_check/email_sign_in'] input[name=email]"
  end

  test "typing the emailed code signs the person in with an email code" do
    post "/door_check/email_sign_in", params: { email: "ada@example.com" }

    post "/door_check/email_code", params: { code: emailed_code }

    get "/proofs"
    assert_equal [ "email_code" ], response.parsed_body
  end

  private

  def emailed_code
    ActionMailer::Base.deliveries.last.text_part.body.to_s[/code is (\d{6})/, 1]
  end
end

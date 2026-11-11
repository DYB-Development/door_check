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

  test "the code screen asks for the emailed code" do
    get "/door_check/email_code/new"

    assert_select "form[action='/door_check/email_code'] input[name=code]"
  end

  test "a wrong code is refused on the screen that asked" do
    post "/door_check/email_sign_in", params: { email: "ada@example.com" }

    post "/door_check/email_code", params: { code: "000000" }

    assert_select "div", text: /That code is not right/
  end

  test "typing the emailed code inside the iOS app signs the person in" do
    ios_app = { "User-Agent" => "Mozilla/5.0 (iPhone; CPU iPhone OS 18_0 like Mac OS X) AppleWebKit/605.1.15 (KHTML, like Gecko) Mobile/15E148 Hotwire Native iOS; Turbo Native iOS" }
    post "/door_check/email_sign_in", params: { email: "ada@example.com" }, headers: ios_app

    post "/door_check/email_code", params: { code: emailed_code }, headers: ios_app

    assert_redirected_to "/"
  end

  test "opening the emailed link signs that browser in with an email link" do
    post "/door_check/email_sign_in", params: { email: "ada@example.com" }
    link = emailed_link
    reset!

    get link
    get "/proofs"

    assert_equal [ "email_link" ], response.parsed_body
  end

  test "a link opened a second time says it no longer works" do
    post "/door_check/email_sign_in", params: { email: "ada@example.com" }
    link = emailed_link
    get link
    reset!

    get link

    assert_select "div", text: /no longer works/
  end

  test "an app that does not offer email codes sends none" do
    offered = DoorCheck.configuration.offered_methods
    DoorCheck.configuration.offered_methods = %i[password]

    assert_no_emails do
      post "/door_check/email_sign_in", params: { email: "ada@example.com" }
    end
  ensure
    DoorCheck.configuration.offered_methods = offered
  end

  test "an app that does not offer email links does not sign in from one" do
    post "/door_check/email_sign_in", params: { email: "ada@example.com" }
    link = emailed_link
    offered = DoorCheck.configuration.offered_methods
    DoorCheck.configuration.offered_methods = %i[password email_code]

    get link

    assert_response :not_found
  ensure
    DoorCheck.configuration.offered_methods = offered
  end

  test "an app that does not offer email codes does not sign in from one" do
    post "/door_check/email_sign_in", params: { email: "ada@example.com" }
    offered = DoorCheck.configuration.offered_methods
    DoorCheck.configuration.offered_methods = %i[password email_link]

    post "/door_check/email_code", params: { code: emailed_code }

    assert_response :not_found
  ensure
    DoorCheck.configuration.offered_methods = offered
  end

  private

  def emailed_link
    URI(ActionMailer::Base.deliveries.last.text_part.body.to_s[%r{http\S+/email_link/\S+}]).path
  end

  def emailed_code
    ActionMailer::Base.deliveries.last.text_part.body.to_s[/code is (\d{6})/, 1]
  end
end

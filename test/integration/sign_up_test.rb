require "test_helper"

class SignUpTest < ActionDispatch::IntegrationTest
  test "a visitor opens the sign-up page and is asked for their name" do
    get "/door_check/sign_up/new"

    assert_select "form[action='/door_check/sign_up'] input[name=name]"
  end

  test "the sign-up page is not found when the host has set no sign-up callable" do
    sign_up_person = DoorCheck.configuration.sign_up_person
    DoorCheck.configuration.sign_up_person = nil

    get "/door_check/sign_up/new"

    assert_response :not_found
  ensure
    DoorCheck.configuration.sign_up_person = sign_up_person
  end

  test "the sign-up page is not found when the host does not offer email codes" do
    offered = DoorCheck.configuration.offered_methods
    DoorCheck.configuration.offered_methods = %i[password email_link]

    get "/door_check/sign_up/new"

    assert_response :not_found
  ensure
    DoorCheck.configuration.offered_methods = offered
  end

  test "submitting the sign-up page passes every submitted value to the host's sign-up callable" do
    received = nil
    with_sign_up_person(->(_controller, values) { received = values.to_h; signed_up(values) }) do
      post "/door_check/sign_up", params: { name: "Ada Lovelace", email: "ada@example.com" }
    end

    assert_equal({ "name" => "Ada Lovelace", "email" => "ada@example.com" }, received)
  end

  test "a value in the sign-up page's address reaches the host's sign-up callable unchanged" do
    received = nil
    with_sign_up_person(->(_controller, values) { received = values; signed_up(values) }) do
      get "/door_check/sign_up/new", params: { invitation: "inv-42/abc" }
      form_action = css_select("form").first["action"]
      post form_action, params: { name: "Ada Lovelace", email: "ada@example.com" }
    end

    assert_equal "inv-42/abc", received[:invitation]
  end

  test "a visitor the host signs up is emailed a sign-in code and link" do
    post "/door_check/sign_up", params: { name: "Ada Lovelace", email: "ada@example.com" }

    assert_match(%r{code is \d{6}.*/email_link/}m, ActionMailer::Base.deliveries.last&.text_part&.body.to_s)
  end

  test "a visitor the host signs up is taken to the screen where the code is typed" do
    post "/door_check/sign_up", params: { name: "Ada Lovelace", email: "ada@example.com" }

    assert_redirected_to "/door_check/email_code/new"
  end

  test "typing the code emailed at sign-up signs the new person in with an email code" do
    post "/door_check/sign_up", params: { name: "Ada Lovelace", email: "ada@example.com" }

    post "/door_check/email_code", params: { code: ActionMailer::Base.deliveries.last.text_part.body.to_s[/code is (\d{6})/, 1] }

    get "/proofs"
    assert_equal [ "email_code" ], response.parsed_body
  end

  test "a sign-up the host refuses shows the host's message on the sign-up page" do
    with_sign_up_person(->(_controller, _values) { refused }) do
      post "/door_check/sign_up", params: { name: "Ada Lovelace", email: "ada@example.com" }
    end

    assert_select "[role=alert]", text: /Sign-up is closed for this team/
  end

  test "a sign-up the host refuses keeps the name the visitor entered" do
    with_sign_up_person(->(_controller, _values) { refused }) do
      post "/door_check/sign_up", params: { name: "Ada Lovelace", email: "ada@example.com" }
    end

    assert_select "input[name=name][value='Ada Lovelace']"
  end

  private

  def refused
    DoorCheck::Result.new(ok: false, message: "Sign-up is closed for this team.")
  end

  def signed_up(values)
    User.create!(email: values[:email])
    DoorCheck::Result.new(ok: true)
  end

  def with_sign_up_person(callable)
    sign_up_person = DoorCheck.configuration.sign_up_person
    DoorCheck.configuration.sign_up_person = callable
    yield
  ensure
    DoorCheck.configuration.sign_up_person = sign_up_person
  end
end

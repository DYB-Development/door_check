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

  test "a visitor on the sign-up page can choose between an emailed code and a password" do
    get "/door_check/sign_up/new"

    assert_equal [ [ "Emailed code", "/door_check/sign_up/new?sign_in_method=email_code" ], [ "Password", "/door_check/sign_up/new?sign_in_method=password" ] ],
                 css_select("a[href*=sign_in_method]").map { |tab| [ tab.text.squish, tab["href"] ] }
  end

  test "a visitor who has not chosen a password is not asked for one on the sign-up page" do
    get "/door_check/sign_up/new"

    assert_select "input[name=password]", count: 0
  end

  test "the sign-up page marks the password as the visitor's choice once they choose it" do
    get "/door_check/sign_up/new", params: { sign_in_method: "password" }

    assert_select "a[aria-current=page]", text: "Password"
  end

  test "a visitor who chooses a password on the sign-up page must fill in a password field" do
    get "/door_check/sign_up/new", params: { sign_in_method: "password" }

    assert_select "input[type=password][name=password][required]"
  end

  test "the sign-up page offers no choice of sign-in when the app offers only email codes" do
    with_configuration(offered_methods: %i[email_code email_link]) do
      get "/door_check/sign_up/new"
    end

    assert_select "a[href*=sign_in_method]", count: 0
  end

  test "the sign-up page asks for a password without a choice when the app offers only passwords" do
    with_configuration(offered_methods: %i[password]) do
      get "/door_check/sign_up/new"
    end

    assert_select "input[type=password][name=password]"
  end

  test "a visitor opens the sign-up page when the host offers passwords but not email codes" do
    with_configuration(offered_methods: %i[password email_link]) do
      get "/door_check/sign_up/new"
    end

    assert_response :ok
  end

  test "the sign-up page is not found when the host offers neither passwords nor email codes" do
    with_configuration(offered_methods: %i[email_link passkey]) do
      get "/door_check/sign_up/new"
    end

    assert_response :not_found
  end

  test "submitting the sign-up page passes every submitted value to the host's sign-up callable" do
    received = nil
    with_sign_up_person(->(_controller, values) { received = values.to_h; signed_up(values) }) do
      post "/door_check/sign_up", params: { name: "Ada Lovelace", email: "ada@example.com", agreement: "1" }
    end

    assert_equal({ "name" => "Ada Lovelace", "email" => "ada@example.com", "agreement" => "1" }, received)
  end

  test "a password chosen at sign-up reaches the host's sign-up callable with the agreement and the other values" do
    received = nil
    with_sign_up_person(->(_controller, values) { received = values.to_h; signed_up(values) }) do
      get "/door_check/sign_up/new", params: { sign_in_method: "password" }
      post css_select("form").first["action"], params: { name: "Ada Lovelace", email: "ada@example.com", password: "correct horse battery", agreement: "1" }
    end

    assert_equal({ "sign_in_method" => "password", "name" => "Ada Lovelace", "email" => "ada@example.com", "password" => "correct horse battery", "agreement" => "1" },
                 received)
  end

  test "a visitor the host signs up with a password is signed in as the new person" do
    post "/door_check/sign_up?sign_in_method=password", params: { name: "Ada Lovelace", email: "ada@example.com", password: "correct horse battery", agreement: "1" }

    assert_equal User.find_by(email: "ada@example.com").id, session[:user_id]
  end

  test "a visitor who signs up with a password has a signed-in session proved by password" do
    post "/door_check/sign_up?sign_in_method=password", params: { name: "Ada Lovelace", email: "ada@example.com", password: "correct horse battery", agreement: "1" }

    get "/proofs"
    assert_equal [ "password" ], response.parsed_body
  end

  test "a value in the sign-up page's address reaches the host's sign-up callable unchanged" do
    received = nil
    with_sign_up_person(->(_controller, values) { received = values; signed_up(values) }) do
      get "/door_check/sign_up/new", params: { invitation: "inv-42/abc" }
      form_action = css_select("form").first["action"]
      post form_action, params: { name: "Ada Lovelace", email: "ada@example.com", agreement: "1" }
    end

    assert_equal "inv-42/abc", received[:invitation]
  end

  test "a visitor the host signs up is emailed a sign-in code and link" do
    post "/door_check/sign_up", params: { name: "Ada Lovelace", email: "ada@example.com", agreement: "1" }

    assert_match(%r{code is \d{6}.*/email_link/}m, ActionMailer::Base.deliveries.last&.text_part&.body.to_s)
  end

  test "a visitor the host signs up is taken to the screen where the code is typed" do
    post "/door_check/sign_up", params: { name: "Ada Lovelace", email: "ada@example.com", agreement: "1" }

    assert_redirected_to "/door_check/email_code/new"
  end

  test "typing the code emailed at sign-up signs the new person in with an email code" do
    post "/door_check/sign_up", params: { name: "Ada Lovelace", email: "ada@example.com", agreement: "1" }

    post "/door_check/email_code", params: { code: ActionMailer::Base.deliveries.last.text_part.body.to_s[/code is (\d{6})/, 1] }

    get "/proofs"
    assert_equal [ "email_code" ], response.parsed_body
  end

  test "a sign-up the host refuses shows the host's message on the sign-up page" do
    with_sign_up_person(->(_controller, _values) { refused }) do
      post "/door_check/sign_up", params: { name: "Ada Lovelace", email: "ada@example.com", agreement: "1" }
    end

    assert_select "[role=alert]", text: /Sign-up is closed for this team/
  end

  test "a sign-up the host refuses keeps the name the visitor entered" do
    with_sign_up_person(->(_controller, _values) { refused }) do
      post "/door_check/sign_up", params: { name: "Ada Lovelace", email: "ada@example.com", agreement: "1" }
    end

    assert_select "input[name=name][value='Ada Lovelace']"
  end

  test "a sign-up the host refuses keeps the email address the visitor entered" do
    with_sign_up_person(->(_controller, _values) { refused }) do
      post "/door_check/sign_up", params: { name: "Ada Lovelace", email: "ada@example.com", agreement: "1" }
    end

    assert_select "input[name=email][value='ada@example.com']"
  end

  test "the sign-up page shows the agreement checkbox with the label the host configured" do
    with_configuration(sign_up_agreement_label: "I agree to the Acme terms") do
      get "/door_check/sign_up/new"
    end

    assert_select "input[type=checkbox][name=agreement] + label", text: "I agree to the Acme terms"
  end

  test "the sign-up page links to each document the host configured for the agreement" do
    links = ->(_controller) { [ { title: "Terms of Service", url: "/terms" }, { title: "Privacy Policy", url: "/privacy" } ] }
    with_configuration(sign_up_agreement_links: links) do
      get "/door_check/sign_up/new"
    end

    assert_equal [ [ "Terms of Service", "/terms" ], [ "Privacy Policy", "/privacy" ] ], css_select("form a").map { |link| [ link.text.squish, link["href"] ] }
  end

  test "a sign-up without the agreement ticked does not reach the host's sign-up callable" do
    called = false
    with_sign_up_person(->(_controller, values) { called = true; signed_up(values) }) do
      post "/door_check/sign_up", params: { name: "Ada Lovelace", email: "ada@example.com", agreement: "0" }
    end

    assert_not called
  end

  test "a sign-up without the agreement ticked asks the visitor to tick it on the sign-up page" do
    post "/door_check/sign_up", params: { name: "Ada Lovelace", email: "ada@example.com", agreement: "0" }

    assert_select "[role=alert]", text: /Tick the agreement to sign up/
  end

  test "a sign-up without the agreement ticked keeps the name the visitor entered" do
    post "/door_check/sign_up", params: { name: "Ada Lovelace", email: "ada@example.com", agreement: "0" }

    assert_select "input[name=name][value='Ada Lovelace']"
  end

  test "a sign-up without the agreement ticked keeps the email address the visitor entered" do
    post "/door_check/sign_up", params: { name: "Ada Lovelace", email: "ada@example.com", agreement: "0" }

    assert_select "input[name=email][value='ada@example.com']"
  end

  test "a ticked agreement reaches the host's sign-up callable" do
    received = nil
    with_sign_up_person(->(_controller, values) { received = values; signed_up(values) }) do
      post "/door_check/sign_up", params: { name: "Ada Lovelace", email: "ada@example.com", agreement: "1" }
    end

    assert_equal "1", received[:agreement]
  end

  test "a sign-up leaves nothing about the agreement in door_check's tables" do
    post "/door_check/sign_up", params: { name: "Ada Lovelace", email: "ada@example.com", agreement: "1" }

    assert_no_match(/agree/i, door_check_rows.to_s)
  end

  private

  def door_check_rows
    connection = ActiveRecord::Base.connection
    connection.tables.grep(/\Adoor_check_/).flat_map { |table| connection.select_all("SELECT * FROM #{table}").to_a }
  end

  def refused
    DoorCheck::Result.new(ok: false, message: "Sign-up is closed for this team.")
  end

  def signed_up(values)
    User.create!(email: values[:email])
    DoorCheck::Result.new(ok: true)
  end

  def with_configuration(**settings)
    previous = settings.keys.index_with { |name| DoorCheck.configuration.public_send(name) }
    settings.each { |name, value| DoorCheck.configuration.public_send("#{name}=", value) }
    yield
  ensure
    previous.each { |name, value| DoorCheck.configuration.public_send("#{name}=", value) }
  end

  def with_sign_up_person(callable)
    sign_up_person = DoorCheck.configuration.sign_up_person
    DoorCheck.configuration.sign_up_person = callable
    yield
  ensure
    DoorCheck.configuration.sign_up_person = sign_up_person
  end
end

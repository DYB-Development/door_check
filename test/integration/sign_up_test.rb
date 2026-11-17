require "test_helper"

class SignUpTest < ActionDispatch::IntegrationTest
  class FailingDelivery
    def initialize(_settings); end

    def deliver!(_mail)
      raise IOError, "The mail server refused the connection"
    end
  end

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

  test "an invitation link opens the sign-up page while the sign-in page shows no sign-up link" do
    DoorCheck.configuration.sign_up_link_on_sign_in = false

    get "/door_check/sign_up/new", params: { invitation: "inv-42/abc" }

    assert_select "form input[name=name]"
  ensure
    DoorCheck.configuration.sign_up_link_on_sign_in = true
  end

  test "a visitor on the sign-up page can choose between an emailed code and a password without reloading the page" do
    get "/door_check/sign_up/new"

    assert_equal [ "Emailed code", "Password" ],
                 css_select("[data-controller=tab-switcher] button[type=button][data-action='click->tab-switcher#select']").map { |tab| tab.text.squish }
  end

  test "the name and email the visitor typed stay filled in when they switch between Password and Emailed code" do
    get "/door_check/sign_up/new"

    assert_equal %w[name email], css_select("[data-controller=tab-switcher] input").reject { |input| input.ancestors("fieldset").any? }.map { |input| input["name"] }
  end

  test "a visitor who has not chosen a password is not asked for one on the sign-up page" do
    get "/door_check/sign_up/new"

    assert_select "fieldset:not([hidden]) input[name=password]", count: 0
  end

  test "a visitor who chooses a password is not told the sign-up page will send a code" do
    get "/door_check/sign_up/new", params: { sign_in_method: "password" }

    assert_no_match(/send you a code/, css_select("fieldset:not([hidden])").text)
  end

  test "a visitor who chooses a password submits the sign-up page with a Sign up button" do
    get "/door_check/sign_up/new", params: { sign_in_method: "password" }

    assert_select "form button[type=submit]", text: "Sign up"
  end

  test "the sign-up page marks the password as the visitor's choice once they choose it" do
    get "/door_check/sign_up/new", params: { sign_in_method: "password" }

    assert_select "fieldset:not([hidden]) input[name=password]"
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

  test "a password sign-up with the password left empty does not reach the host's sign-up callable" do
    called = false
    with_sign_up_person(->(_controller, values) { called = true; signed_up(values) }) do
      post "/door_check/sign_up?sign_in_method=password", params: { name: "Ada Lovelace", email: "ada@example.com", password: "", agreement: "1" }
    end

    assert_not called
  end

  test "a password sign-up with the password left empty asks the visitor for a password" do
    post "/door_check/sign_up?sign_in_method=password", params: { name: "Ada Lovelace", email: "ada@example.com", password: "", agreement: "1" }

    assert_select "[role=alert]", text: /Enter a password to sign up/
  end

  test "a visitor who signs up with a password is sent no sign-in code" do
    post "/door_check/sign_up?sign_in_method=password", params: { name: "Ada Lovelace", email: "ada@example.com", password: "correct horse battery", agreement: "1" }

    assert_empty ActionMailer::Base.deliveries.select { |mail| mail.subject == "Your sign-in code" }
  end

  test "a visitor who signs up with a password is emailed a confirmation link at the address they entered" do
    post "/door_check/sign_up?sign_in_method=password", params: { name: "Ada Lovelace", email: "ada@example.com", password: "correct horse battery", agreement: "1" }

    assert_match %r{/door_check/confirm_email/}, ActionMailer::Base.deliveries.find { |mail| mail.to == [ "ada@example.com" ] }&.text_part&.body.to_s
  end

  test "a visitor who signs up with a password has a signed-in session proved by password" do
    post "/door_check/sign_up?sign_in_method=password", params: { name: "Ada Lovelace", email: "ada@example.com", password: "correct horse battery", agreement: "1" }

    get "/proofs"
    assert_equal [ "password" ], response.parsed_body
  end

  test "a visitor who signs up with a password and asks for the confirmation email again is sent it at the address they entered" do
    post "/door_check/sign_up?sign_in_method=password", params: { name: "Ada Lovelace", email: "ada@example.com", password: "correct horse battery", agreement: "1" }

    post "/door_check/email_confirmation"

    assert_equal [ "ada@example.com" ], ActionMailer::Base.deliveries.last.to
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

  test "a visitor who signs up with the emailed code reads as confirmed once they type it" do
    post "/door_check/sign_up", params: { name: "Ada Lovelace", email: "ada@example.com", agreement: "1" }

    post "/door_check/email_code", params: { code: ActionMailer::Base.deliveries.last.text_part.body.to_s[/code is (\d{6})/, 1] }

    assert DoorCheck::EmailConfirmation.confirmed?(User.find_by(email: "ada@example.com"), "ada@example.com")
  end

  test "a visitor who signs up with the emailed code is sent no confirmation email" do
    post "/door_check/sign_up", params: { name: "Ada Lovelace", email: "ada@example.com", agreement: "1" }

    assert_empty ActionMailer::Base.deliveries.select { |mail| mail.subject == "Confirm your email address" }
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

  test "a password the host refuses shows the host's message on the sign-up page" do
    with_sign_up_person(->(_controller, _values) { password_too_short }) do
      post "/door_check/sign_up?sign_in_method=password", params: { name: "Ada Lovelace", email: "ada@example.com", password: "short", agreement: "1" }
    end

    assert_select "[role=alert]", text: /Choose a password of at least 12 characters/
  end

  test "a password the host refuses keeps the name the visitor entered" do
    with_sign_up_person(->(_controller, _values) { password_too_short }) do
      post "/door_check/sign_up?sign_in_method=password", params: { name: "Ada Lovelace", email: "ada@example.com", password: "short", agreement: "1" }
    end

    assert_select "input[name=name][value='Ada Lovelace']"
  end

  test "a password the host refuses keeps the email address the visitor entered" do
    with_sign_up_person(->(_controller, _values) { password_too_short }) do
      post "/door_check/sign_up?sign_in_method=password", params: { name: "Ada Lovelace", email: "ada@example.com", password: "short", agreement: "1" }
    end

    assert_select "input[name=email][value='ada@example.com']"
  end

  test "a password the host refuses leaves the visitor's password choice on the sign-up page" do
    with_sign_up_person(->(_controller, _values) { password_too_short }) do
      get "/door_check/sign_up/new", params: { sign_in_method: "password" }
      post css_select("form").first["action"], params: { name: "Ada Lovelace", email: "ada@example.com", password: "short", agreement: "1" }
    end

    assert_select "input[type=password][name=password]"
  end

  test "a password the host refuses is not filled back in on the sign-up page" do
    with_sign_up_person(->(_controller, _values) { password_too_short }) do
      post "/door_check/sign_up?sign_in_method=password", params: { name: "Ada Lovelace", email: "ada@example.com", password: "short", agreement: "1" }
    end

    assert_select "input[name=password][value]", count: 0
  end

  test "the dummy app's sign-up callable refuses a password shorter than 12 characters" do
    post "/door_check/sign_up?sign_in_method=password", params: { name: "Ada Lovelace", email: "ada@example.com", password: "short", agreement: "1" }

    assert_select "[role=alert]", text: /Choose a password of at least 12 characters/
  end

  test "the sign-up page shows the agreement checkbox with the label the host configured" do
    with_configuration(sign_up_agreement_label: "I agree to the Acme terms") do
      get "/door_check/sign_up/new"
    end

    assert_select "input[type=checkbox][name=agreement] + label", text: "I agree to the Acme terms"
  end

  test "the browser will not submit the sign-up page until the agreement is ticked" do
    get "/door_check/sign_up/new"

    assert_select "input[type=checkbox][name=agreement][required]"
  end

  test "the sign-up page links to each document the host configured for the agreement" do
    links = ->(_controller) { [ { title: "Terms of Service", url: "/terms" }, { title: "Privacy Policy", url: "/privacy" } ] }
    with_configuration(sign_up_agreement_links: links) do
      get "/door_check/sign_up/new"
    end

    assert_equal [ [ "Terms of Service", "/terms" ], [ "Privacy Policy", "/privacy" ] ], css_select("form a").map { |link| [ link.text.squish, link["href"] ] }
  end

  test "the agreement's documents open in a new tab so the visitor keeps the sign-up page" do
    links = ->(_controller) { [ { title: "Terms of Service", url: "/terms" }, { title: "Privacy Policy", url: "/privacy" } ] }
    with_configuration(sign_up_agreement_links: links) do
      get "/door_check/sign_up/new"
    end

    assert_equal [ [ "_blank", "noopener" ] ] * 2, css_select("form a").map { |link| [ link["target"], link["rel"] ] }
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

  test "a password sign-up without the agreement ticked does not reach the host's sign-up callable" do
    called = false
    with_sign_up_person(->(_controller, values) { called = true; signed_up(values) }) do
      post "/door_check/sign_up?sign_in_method=password", params: { name: "Ada Lovelace", email: "ada@example.com", password: "correct horse battery", agreement: "0" }
    end

    assert_not called
  end

  test "a password sign-up without the agreement ticked asks the visitor to tick it on the sign-up page" do
    post "/door_check/sign_up?sign_in_method=password", params: { name: "Ada Lovelace", email: "ada@example.com", password: "correct horse battery", agreement: "0" }

    assert_select "[role=alert]", text: /Tick the agreement to sign up/
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

  test "a password sign-up leaves the password in none of door_check's tables" do
    post "/door_check/sign_up?sign_in_method=password", params: { name: "Ada Lovelace", email: "ada@example.com", password: "correct horse battery", agreement: "1" }

    assert_no_match(/correct horse battery/, door_check_rows.to_s)
  end

  test "a password sign-up with an address that already has an account does not reach the host's sign-up callable" do
    User.create!(email: "ada@example.com")
    called = false
    with_sign_up_person(->(_controller, values) { called = true; signed_up(values) }) do
      post "/door_check/sign_up?sign_in_method=password", params: { name: "Ada Lovelace", email: "ada@example.com", password: "correct horse battery", agreement: "1" }
    end

    assert_not called
  end

  test "an emailed-code sign-up with an address that already has an account does not reach the host's sign-up callable" do
    User.create!(email: "ada@example.com")
    called = false
    with_sign_up_person(->(_controller, values) { called = true; signed_up(values) }) do
      post "/door_check/sign_up", params: { name: "Ada Lovelace", email: "ada@example.com", agreement: "1" }
    end

    assert_not called
  end

  test "a sign-up with an address that already has an account emails that address a sign-in code and link" do
    User.create!(email: "ada@example.com")

    post "/door_check/sign_up", params: { name: "Ada Lovelace", email: "ada@example.com", agreement: "1" }

    assert_match(%r{code is \d{6}.*/email_link/}m, ActionMailer::Base.deliveries.find { |mail| mail.to == [ "ada@example.com" ] }&.text_part&.body.to_s)
  end

  test "a password sign-up with an address that already has an account is taken to the screen where the code is typed" do
    User.create!(email: "ada@example.com")

    post "/door_check/sign_up?sign_in_method=password", params: { name: "Ada Lovelace", email: "ada@example.com", password: "correct horse battery", agreement: "1" }

    assert_redirected_to "/door_check/email_code/new"
  end

  test "an emailed-code sign-up with an address that already has an account is taken to the screen where the code is typed" do
    User.create!(email: "ada@example.com")

    post "/door_check/sign_up", params: { name: "Ada Lovelace", email: "ada@example.com", agreement: "1" }

    assert_redirected_to "/door_check/email_code/new"
  end

  test "a password sign-up with an address that already has an account does not sign the visitor in" do
    User.create!(email: "ada@example.com")

    post "/door_check/sign_up?sign_in_method=password", params: { name: "Ada Lovelace", email: "ada@example.com", password: "correct horse battery", agreement: "1" }

    assert_nil session[:user_id]
  end

  test "a sign-up the host accepts without making a findable person tells the visitor sign-up could not be finished" do
    with_sign_up_person(->(_controller, _values) { DoorCheck::Result.new(ok: true) }) do
      post "/door_check/sign_up", params: { name: "Ada Lovelace", email: "ada@example.com", agreement: "1" }
    end

    assert_select "[role=alert]", text: /Sign-up could not be finished/
  end

  test "a password sign-up the host accepts without making a findable person does not sign the visitor in" do
    with_sign_up_person(->(_controller, _values) { DoorCheck::Result.new(ok: true) }) do
      post "/door_check/sign_up?sign_in_method=password", params: { name: "Ada Lovelace", email: "ada@example.com", password: "correct horse battery", agreement: "1" }
    end

    assert_nil session[:user_id]
  end

  test "an emailed-code sign-up the host accepts without making a findable person sends no email" do
    with_sign_up_person(->(_controller, _values) { DoorCheck::Result.new(ok: true) }) do
      post "/door_check/sign_up", params: { name: "Ada Lovelace", email: "ada@example.com", agreement: "1" }
    end

    assert_empty ActionMailer::Base.deliveries
  end

  test "a password sign-up the host accepts without making a findable person sends no email" do
    with_sign_up_person(->(_controller, _values) { DoorCheck::Result.new(ok: true) }) do
      post "/door_check/sign_up?sign_in_method=password", params: { name: "Ada Lovelace", email: "ada@example.com", password: "correct horse battery", agreement: "1" }
    end

    assert_empty ActionMailer::Base.deliveries
  end

  test "a sign-up whose host callable raises an error tells the visitor sign-up could not be finished" do
    with_sign_up_person(->(_controller, _values) { raise "The host's database is down" }) do
      post "/door_check/sign_up", params: { name: "Ada Lovelace", email: "ada@example.com", agreement: "1" }
    end

    assert_select "[role=alert]", text: /Sign-up could not be finished/
  end

  test "an error raised by the host's sign-up callable is reported to the app's error reporter" do
    assert_error_reported(RuntimeError) do
      with_sign_up_person(->(_controller, _values) { raise "The host's database is down" }) do
        post "/door_check/sign_up", params: { name: "Ada Lovelace", email: "ada@example.com", agreement: "1" }
      end
    end
  end

  test "a password sign-up whose host callable raises an error after making the person does not sign the visitor in" do
    with_sign_up_person(->(_controller, values) { signed_up(values); raise "The host's welcome email failed" }) do
      post "/door_check/sign_up?sign_in_method=password", params: { name: "Ada Lovelace", email: "ada@example.com", password: "correct horse battery", agreement: "1" }
    end

    assert_nil session[:user_id]
  end

  test "an emailed-code sign-up whose host callable raises an error after making the person sends no email" do
    with_sign_up_person(->(_controller, values) { signed_up(values); raise "The host's welcome email failed" }) do
      post "/door_check/sign_up", params: { name: "Ada Lovelace", email: "ada@example.com", agreement: "1" }
    end

    assert_empty ActionMailer::Base.deliveries
  end

  test "a password sign-up whose host callable raises an error after making the person sends no confirmation email" do
    with_sign_up_person(->(_controller, values) { signed_up(values); raise "The host's welcome email failed" }) do
      post "/door_check/sign_up?sign_in_method=password", params: { name: "Ada Lovelace", email: "ada@example.com", password: "correct horse battery", agreement: "1" }
    end

    assert_empty ActionMailer::Base.deliveries
  end

  test "a visitor who signs up with a password stays signed in when the confirmation email cannot be sent" do
    with_failing_mail do
      post "/door_check/sign_up?sign_in_method=password", params: { name: "Ada Lovelace", email: "ada@example.com", password: "correct horse battery", agreement: "1" }
    end

    assert_equal User.find_by(email: "ada@example.com").id, session[:user_id]
  end

  test "a person whose confirmation email could not be sent at sign-up is still offered to send it again" do
    with_failing_mail do
      post "/door_check/sign_up?sign_in_method=password", params: { name: "Ada Lovelace", email: "ada@example.com", password: "correct horse battery", agreement: "1" }
    end

    assert DoorCheck::EmailConfirmation.for(User.find_by(email: "ada@example.com")).awaiting?
  end

  test "a confirmation email that cannot be sent at sign-up is reported to the app's error reporter" do
    assert_error_reported(IOError) do
      with_failing_mail do
        post "/door_check/sign_up?sign_in_method=password", params: { name: "Ada Lovelace", email: "ada@example.com", password: "correct horse battery", agreement: "1" }
      end
    end
  end

  test "a password submitted on the sign-up page is kept out of the request log when the host app filters no password" do
    log = with_request_log_and_no_host_password_filter do
      post "/door_check/sign_up?sign_in_method=password", params: { name: "Ada Lovelace", email: "ada@example.com", password: "correct horse battery", agreement: "1" }
    end

    assert_no_match(/correct horse battery/, log)
  end

  private

  def door_check_rows
    connection = ActiveRecord::Base.connection
    connection.tables.grep(/\Adoor_check_/).flat_map { |table| connection.select_all("SELECT * FROM #{table}").to_a }
  end

  def refused
    DoorCheck::Result.new(ok: false, message: "Sign-up is closed for this team.")
  end

  def password_too_short
    DoorCheck::Result.new(ok: false, message: "Choose a password of at least 12 characters.")
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

  def with_request_log_and_no_host_password_filter
    filters = Rails.application.config.filter_parameters
    original_filters = filters.dup
    original_logger = ActionController::Base.logger
    log = StringIO.new
    filters.delete(:passw)
    ActionController::Base.logger = ActiveSupport::Logger.new(log)
    yield
    log.string
  ensure
    ActionController::Base.logger = original_logger
    filters.replace(original_filters)
  end

  def with_failing_mail
    ActionMailer::Base.add_delivery_method :failing, FailingDelivery
    ActionMailer::Base.delivery_method = :failing
    yield
  ensure
    ActionMailer::Base.delivery_method = :test
  end

  def with_sign_up_person(callable)
    sign_up_person = DoorCheck.configuration.sign_up_person
    DoorCheck.configuration.sign_up_person = callable
    yield
  ensure
    DoorCheck.configuration.sign_up_person = sign_up_person
  end
end

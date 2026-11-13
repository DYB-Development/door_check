---
name: door_check-develop
description: Use PROACTIVELY for recording a sign-in made by the host's own sign-in page, reading what the current session has proved and the current account, checking sign-in method names, writing the settings actions that change a person's or an account's second-step rule, remove a saved sign-in method, sign out a session or forget a trusted browser, handling the result those actions return, and linking to door_check's sign-in, approval and setup pages — MUST BE USED instead of hand-writing session tracking, second-step rules, sign-out of other devices or sign-in method records.
tools: Bash, Read, Write, Edit, Grep
scope: sign-in — the sign-in methods and second steps an app offers, each account narrows, and each person chooses from
---

This local writes host code that calls door_check once it is installed. It
documents only the calls below. Where a step names a decision, ask the developer
and do not pick for them.

## What door_check is

A Rails engine that adds sign-in methods and second steps to an app that already
has its own users, session and sign-in page. Use this local when host code signs
someone in, reads what a session has proved, changes a sign-in rule, ends a
session, removes a saved method, forgets a trusted browser, or links to a
door_check page.

## Interface

Host controller methods, available in every host controller once the install
local has added door_check's tracking:

- `door_check_signed_in(person, method_name:)` — records a new signed-in session for `person` on this device, records `method_name` as its first proof, and makes it this browser's door_check session.
- `door_check_proved_by` — the current session's proofs, oldest first, as `[method_name, proved_at]` pairs with the name as a symbol, or `[]` when no one is signed in or the sign-in was never recorded.
- `door_check_account` — the current account, read through the host's account method, or nil when the host has no account method.

Method names:

- `DoorCheck::Methods.names` — every method name door_check knows, as symbols: `password`, `email_code`, `email_link`, `device_approval`, `authenticator_app`, `sms_code`, `passkey`, `backup_codes`, `trusted_device`, `google`, `apple`, `sso`.
- `DoorCheck::UnknownMethod` — the error raised at boot when the app's offered methods include a name outside `DoorCheck::Methods.names`.

Rule and session actions. Each is built with `person:`, `account:` and
`values:`, all three required, and `call` returns a `DoorCheck::Result`:

- `DoorCheck::RequireSecondStep` — saves the account's rule: the methods it accepts from `values[:accepted_methods]`, whether it requires a second step from `values[:second_step_required]`, and whether its members choose their own second step from `values[:members_choose_second_step]`.
- `DoorCheck::RequireOwnSecondStep` — saves the person's own rule: whether they require a second step, from `values[:second_step_required]`.
- `DoorCheck::RemoveMethod` — removes the person's saved method whose id is `values[:credential_id]`.
- `DoorCheck::SignOutSession` — signs out the person's signed-in session whose id is `values[:signed_in_session_id]`.
- `DoorCheck::RemoveTrustedBrowser` — forgets the person's trusted browser whose id is `values[:trusted_device_id]`.
- `DoorCheck::Result` — `ok?` is true when the action succeeded, and `message` is the text to show the person when it did not.

Paths, called on the engine's route proxy `door_check` from host views and
controllers:

- `door_check.new_email_sign_in_path` — the page where a person enters their email to be sent a sign-in code and a sign-in link.
- `door_check.new_passkey_sign_in_path` — the page where a person signs in with a passkey.
- `door_check.new_approval_request_path` — the page where a person asks to be let in by approving from a device they are already signed in on.
- `door_check.approvals_path` — the page where a signed-in person sees waiting approval requests and approves or declines them.
- `door_check.new_authenticator_path` — the page where a signed-in person sets up an authenticator app by scanning a QR code or typing a secret key, then entering the code the app shows.
- `door_check.new_passkey_path` — the page where a signed-in person adds a passkey or hardware key.
- `door_check.backup_codes_path` — makes a new set of backup codes for the signed-in person and shows them. It takes a `POST` only.

## How to use it

### Record a sign-in made by the host

1. Find every place the host signs a person in itself, such as its password
   sign-in. door_check's own sign-in pages record their sign-ins, so only the
   host's own need this.
2. Right after the host sets its own session, record the sign-in with the
   method the person used:
   ```ruby
   class SessionsController < ApplicationController
     def create
       user = User.authenticate_by(email: params[:email], password: params[:password])
       return redirect_to new_session_path, alert: "Wrong email or password." unless user

       session[:user_id] = user.id
       door_check_signed_in(user, method_name: :password)
       redirect_to root_path
     end
   end
   ```
   Everything except the `door_check_signed_in` line is an example. Keep the
   host's own sign-in as it is. Pass a name from `DoorCheck::Methods.names`,
   since door_check does not check the name when it records it.
3. A sign-in that is not recorded has no door_check session. Its proofs are
   empty, so a person or account that requires a second step is sent to the
   second-step page on every request. It is not listed among the person's
   sessions, and it cannot be signed out from the settings section.

### Read proofs and the account

```ruby
proved = door_check_proved_by.map(&:first)
proved.include?(:authenticator_app)
```

`door_check_account` returns what the host's account method returns, so use it
where host code needs the same account door_check checks rules against.

### Write the settings actions

The install local placed the two settings sections and pointed them at host
routes that take a `PATCH`. Write those routes and the actions behind them. The
route and controller names below are examples. Match the URLs the sections were
given.

```ruby
# config/routes.rb
resource :settings, only: [] do
  patch :own_second_step
  patch :remove_sign_in_method
  patch :sign_out_session
  patch :remove_trusted_browser
  patch :sign_in_rules
end
```

```ruby
class SettingsController < ApplicationController
  def own_second_step
    finish DoorCheck::RequireOwnSecondStep.new(person: current_user, account: door_check_account,
                                               values: params.permit(:second_step_required)).call
  end

  def remove_sign_in_method
    finish DoorCheck::RemoveMethod.new(person: current_user, account: door_check_account,
                                       values: params.permit(:credential_id)).call
  end

  def sign_out_session
    finish DoorCheck::SignOutSession.new(person: current_user, account: door_check_account,
                                         values: params.permit(:signed_in_session_id)).call
  end

  def remove_trusted_browser
    finish DoorCheck::RemoveTrustedBrowser.new(person: current_user, account: door_check_account,
                                               values: params.permit(:trusted_device_id)).call
  end

  def sign_in_rules
    finish DoorCheck::RequireSecondStep.new(person: current_user, account: door_check_account,
                                            values: params.permit(:second_step_required, :members_choose_second_step,
                                                                  accepted_methods: [])).call
  end

  private

  def finish(result)
    if result.ok?
      redirect_back fallback_location: root_path
    else
      redirect_back fallback_location: root_path, alert: result.message
    end
  end
end
```

`current_user` stands for the host's person method. Use the same method the
install local gave door_check as the person method.

What each section sends, and what the action does with it:

- When the app is set so people do not choose their own second step, the
  person section shows the alert "This app decides when you are asked for a
  second step." in place of the second-step checkbox, whatever the account
  allows, and sends nothing to the own second-step route.
- Otherwise the person section shows its second-step checkbox only while the
  account it was rendered with lets members choose, or when it was rendered
  with no account. When the account does not let members choose, it shows the
  alert "Your account decides whether you are asked for a second step." in
  place of the checkbox, and sends nothing to the own second-step route.
- The person section's second-step form sends `second_step_required`.
  `RequireOwnSecondStep` saves the rule as on when the value is `"1"` and off
  for any other value.
- The person section's Remove on a saved method sends `credential_id`.
  `RemoveMethod` removes that method only when it belongs to `person`.
- The person section's Sign out on a session sends `signed_in_session_id`.
  `SignOutSession` signs that session out only when it belongs to `person` and
  is still signed in. The device it was on is signed out of the host on its
  next request and sent to `/`.
- The person section's Remove on a trusted browser sends `trusted_device_id`.
  `RemoveTrustedBrowser` forgets that browser only when it belongs to `person`,
  and the browser is asked for a second step again.
- The account section sends `accepted_methods[]`, one value per ticked method,
  `second_step_required` and `members_choose_second_step`. `RequireSecondStep`
  refuses the save when a ticked method is not one the app offers, and returns
  a result whose `ok?` is false and whose `message` is
  `"Pick only methods this app offers."`. Otherwise it saves the values to the
  rule of the `account` it was given, with the second step on only when
  `second_step_required` is `"1"` and members choosing only when
  `members_choose_second_step` is `"1"`.
- When the app is set so people do not choose their own second step, the
  account section shows the alert "This app decides when members are asked for
  a second step." in place of the members checkbox, and sends no
  `members_choose_second_step`.
- Permit `members_choose_second_step` in the `sign_in_rules` action. When
  `values` has no `members_choose_second_step` key, `RequireSecondStep` leaves
  the account's setting as it was, so an action that does not permit it never
  changes it.

Ask the developer who may save the account's rules. door_check does not check
it, so the `sign_in_rules` action must refuse anyone the host does not allow,
before building `RequireSecondStep`.

### Link to door_check's pages

```erb
<%= link_to "Email me a sign-in code", door_check.new_email_sign_in_path %>
<%= link_to "Sign in with a passkey", door_check.new_passkey_sign_in_path %>
<%= link_to "Approve from another device", door_check.new_approval_request_path %>
<%= link_to "Sign-in requests", door_check.approvals_path %>
<%= link_to "Set up an authenticator app", door_check.new_authenticator_path %>
<%= link_to "Add a passkey", door_check.new_passkey_path %>
<%= button_to "Make new backup codes", door_check.backup_codes_path %>
```

1. Ask the developer which methods the app offers, or read the host's door_check
   initializer, and show a link only when its method is offered:
   - the email sign-in page needs `email_code`
   - both passkey pages need `passkey`
   - the approval request page and the approvals page need `device_approval`
   - the authenticator page needs `authenticator_app`
   - the backup codes action needs `backup_codes`
2. The email sign-in, passkey, approval request and backup codes pages return
   not found when their method is not offered. The approvals page and the
   authenticator page do not, so a link to either shown without its method
   offered leads to a working page for a method the app does not offer.
3. The sign-in email always carries both a code and a link. The link returns
   not found unless `email_link` is offered, so ask the developer whether to
   offer `email_link` whenever `email_code` is offered.
4. Put the sign-in links on the host's sign-in page, for a person who is not
   signed in. The approvals, authenticator, passkey and backup codes links are
   for a signed-in person only.
5. Link to `backup_codes_path` with a form that sends a `POST`, such as
   `button_to`, never a plain link.
6. When the person already has a second step set up, the authenticator, passkey
   and backup codes pages first ask for it if this session has not passed one,
   then send the person back.
7. The authenticator page keeps showing the same secret key in this browser
   session until setup succeeds, so reloading it or entering a wrong code does
   not change the key the person already scanned. A wrong code shows an error on
   the same page and saves nothing.
8. When the browser session no longer holds the key, such as after the person
   signed out and back in, saving a code sends the person back to the
   authenticator page with a new key and a warning to scan it again.
9. A right code saves the authenticator app, counts as this session's second
   step, and sends the person to the page they were on before door_check asked
   for a second step, or to `/` when there was none. The app lists the account
   under the person's email when the person responds to `email`.

## Conventions

- Never edit door_check's records directly. Change rules, sessions, saved methods
  and trusted browsers through the five actions above.
- Pass the five actions the person from the host's person method and the
  account from `door_check_account`. `RequireOwnSecondStep`, `RemoveMethod`,
  `SignOutSession` and `RemoveTrustedBrowser` take `account:` but do not use it.
- `RequireOwnSecondStep`, `RemoveMethod`, `SignOutSession` and
  `RemoveTrustedBrowser` always return a result whose `ok?` is true. An id
  that does not belong to the person changes nothing and still returns true.
- When no `accepted_methods[]` box is ticked, the form sends none and the
  account's rule is saved as accepting every offered method.
- An account lets its members choose their own second step until its rule is
  saved with `members_choose_second_step` off.
- While the app lets people choose and the current account lets members
  choose, a person's rule and the account's rule both apply, so a person who requires a second step is asked
  for one whatever the account requires.
- While the current account does not let members choose, the person's own rule
  is not in force there, and only the account's rule decides whether a second
  step is asked for. The person's saved choice is kept, and it applies again
  once the account lets members choose.
- When `door_check_account` is nil, the person's own rule is in force unless
  the app is set so people do not choose their own second step.
- While the app is set so people do not choose their own second step, no
  person's own rule is in force in any account or with no account, and only
  the account's rule decides whether a second step is asked for. Each person's
  saved choice is kept, and it applies again once the app lets people choose.
  Read the host's door_check initializer, or ask the developer, to learn which
  way the app is set.
- Out of scope: adding the gem, its migrations, its routes, its settings, the
  host controller's tracking and second-step check, and placing the settings
  sections. Those belong to the install local.

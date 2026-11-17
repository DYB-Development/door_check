---
name: door_check-install
description: Use to hook door_check into a project — adding the gem, copying its migrations, mounting its routes, setting up the cache that counts confirmation email requests, configuring the offered methods and the host's person, account, sign-in and sign-out hooks, the parent controller and mailer, the passkey domain, the IP lookup, the stylesheet and head partial, the name shown in authenticator apps, whether people may choose their own second step, the callable that creates a person from the sign-up page, the sign-up page's agreement label and the documents linked under it, whether the email sign-in page links to the sign-up page, the callable that saves a person's new email address once they open the link that confirms it, the callable told when a person cancels an email change from the notice sent to their current address, the confirmation email sent after a password sign-up and what the app holds back from a person whose address is not confirmed, adding the sign-in tracking and second-step check to the host's controller, and placing the two settings sections.
tools: Bash, Read, Edit
scope: sign-in — the sign-in methods and second steps an app offers, each account narrows, and each person chooses from
---

This local follows these steps exactly and invents none. Where a step names a
decision, ask the developer and do not pick for them.

## What door_check is

A Rails engine that adds sign-in methods and second steps to an app that already
has its own users, session and sign-in page. Hook it in when the app needs email
codes or links, passkeys, device approval, an authenticator app, backup codes or
trusted browsers.

## Interface

- `gem "door_check"` — adds the engine, and with it keystone_ui, rotp, rqrcode, webauthn and turbo-rails.
- `bin/rails door_check:install:migrations` — copies door_check's migrations into the host's `db/migrate`.
- `mount DoorCheck::Engine` — puts door_check's pages under a path in the host's routes.
- `DoorCheck.configure` — the block, in a host initializer, that holds every setting below.
- `config.offered_methods` — the methods this app turns on, as an array of symbols.
- `config.person_method` — the name of the host controller method that returns the signed-in person, or nil.
- `config.account_method` — the name of the host controller method that returns the current account, or nil to have no accounts.
- `config.person_accounts` — a lambda taking a person and returning the accounts they belong to.
- `config.find_person_by_email` — a lambda taking an email and returning the person, or nil.
- `config.sign_in_person` — a lambda taking the controller and a person, which signs that person in with the host's own session.
- `config.sign_out_person` — a lambda taking the controller, which signs the current person out of the host's own session.
- `config.existing_authenticator` — the class name, as a string, of an authenticator the host already has.
- `config.parent_controller` — the controller door_check's controllers inherit from, as a string.
- `config.parent_mailer` — the mailer door_check's mailer inherits from, as a string.
- `config.passkey_domain` — the domain passkeys are registered to.
- `config.locate_ip` — a lambda taking an IP address and returning a place name to show on approval requests.
- `config.stylesheet` — the stylesheet door_check's pages link.
- `config.head_partial` — a host partial rendered at the end of the head of door_check's pages.
- `config.authenticator_issuer` — the name an authenticator app shows above the account it adds during setup.
- `config.people_choose_second_step` — whether people may require a second step on their own login, true or false.
- `config.sign_up_person` — a lambda taking the controller and the sign-up page's values, which creates the person and returns a `DoorCheck::Result`, or nil to turn the sign-up page off.
- `config.sign_up_agreement_label` — the text beside the sign-up page's agreement checkbox, as a string.
- `config.sign_up_agreement_links` — a lambda taking the controller and returning the documents linked under the agreement checkbox, as an array of `{ title:, url: }` hashes.
- `config.sign_up_link_on_sign_in` — whether the email sign-in page shows a "Create an account" button linking to the sign-up page, true or false.
- `config.email_change_confirmed` — a lambda taking the controller, the person and the new email address, which saves that address as the person's own and returns a `DoorCheck::Result`.
- `config.email_change_cancelled` — a lambda taking the controller, the person and the new email address, called when the person cancels that change from the notice sent to their current address. Its return value is ignored.
- `include DoorCheck::Tracking` — adds sign-in recording and the reads of proofs and the current account to the host's controller.
- `include DoorCheck::EntryCheck` — adds the second-step check to the host's controller.
- `before_action :door_check_check_entry` — runs that check on every host request.
- `door_check/settings/sign_in_methods` — the partial a person uses to see and remove their methods, sessions and trusted browsers, set up new ones, and require a second step on their own login.
- `door_check/settings/sign_in_rules` — the partial an account admin uses to choose which offered methods the account accepts, whether it requires a second step, and whether its members' own second-step choice applies inside it.

## How to use it

1. Add the gem to the host's `Gemfile` and install it:
   ```ruby
   gem "door_check"
   ```
   ```
   bundle install
   ```
   door_check's pages are built with keystone_ui 0.100.0 or later. If the host
   does not already have keystone_ui installed, hand that to the keystone_ui
   install local before going on. If the host's `Gemfile` holds keystone_ui
   below 0.100.0, `bundle install` fails, so ask the developer before raising
   that version.

2. Copy and run the migrations:
   ```
   bin/rails door_check:install:migrations
   bin/rails db:migrate
   ```
   This adds door_check's tables for signed-in sessions, proofs, account rules,
   person rules, credentials, challenges, trusted devices and email
   confirmations, and the email address and purpose of each challenge. People
   and accounts are referenced polymorphically, so the host's own tables are
   not changed. A host upgrading from an earlier door_check gets the email
   confirmations table and the challenges' email and purpose columns from
   these two commands. People who existed before then read as not confirmed
   until they use an email code or link.

3. Mount the engine in `config/routes.rb`:
   ```ruby
   mount DoorCheck::Engine => "/door_check"
   ```
   Ask the developer which path to mount it at. `/door_check` is only an example.

4. Make sure Active Record encryption is configured. door_check encrypts the
   secrets of saved methods, so the host needs
   `active_record.encryption.primary_key`, `deterministic_key` and
   `key_derivation_salt` set, in credentials or in `config/application.rb`. If
   they are missing, run `bin/rails db:encryption:init` and ask the developer
   where to store the output.

5. Make sure every environment sets `config.action_mailer.default_url_options`
   with a host, in `config/environments/*.rb`. The sign-in email, the
   confirmation email, the email sent to confirm a new address and the notice
   sent to the current address about that change each carry a link built
   from it.

6. Check `config.cache_store` in each `config/environments/*.rb`. door_check
   lets a person ask for the confirmation email five times in an hour, and
   counts those requests in the host's Rails cache.
   - Under `:null_store` nothing is counted, so no request is ever refused.
     Rails sets `:null_store` in development unless caching is turned on with
     `bin/rails dev:cache`.
   - Under `:memory_store` each server process keeps its own count, so a host
     running several processes lets a person ask more than five times.
   - A store shared by every process, such as `:solid_cache_store`,
     `:redis_cache_store` or `:mem_cache_store`, applies the limit as stated.

   Ask the developer which store production uses when it is not a shared one.
   door_check adds no cache setting of its own.

7. Create `config/initializers/door_check.rb`:
   ```ruby
   DoorCheck.configure do |config|
     config.offered_methods = %i[password email_code email_link device_approval passkey authenticator_app backup_codes trusted_device]
     config.person_method = :current_user
     config.account_method = :current_account
     config.person_accounts = ->(user) { user.accounts }
     config.find_person_by_email = ->(email) { User.find_by(email: email) }
     config.sign_in_person = ->(controller, user) { controller.session[:user_id] = user.id }
     config.sign_out_person = ->(controller) { controller.session.delete(:user_id) }
   end
   ```
   Every value above is an example. Fill each from the host, and ask about each
   of these:
   - **Offered methods.** Which methods the app turns on. The known names are
     `password`, `email_code`, `email_link`, `device_approval`, `passkey`,
     `authenticator_app`, `sms_code`, `backup_codes`, `trusted_device`,
     `google`, `apple` and `sso`. A name outside this list raises an error at
     boot. door_check's page for a method not offered returns not found.
     `email_code` turns on the email sign-in page, and `email_link` turns on the
     link in that same email.
   - **Person and account.** Read the host's controller to find the methods that
     return the signed-in user and the current account. If the host has no
     accounts, leave `account_method` unset. Each account that
     `person_accounts` returns must respond to `name`.
   - **Sign in and sign out.** The two lambdas must do exactly what the host's
     own sign-in and sign-out do to the session. Read the host's sessions
     controller and copy it. Ask the developer if it is not clear.
   - **`find_person_by_email`** is required when `email_code`, `email_link` or
     `device_approval` is offered.

8. Add the optional settings only when the developer wants them:
   - `config.existing_authenticator = "StoredAuthenticator"` — when the host
     already has an authenticator app or backup codes of its own. The class is
     built with no arguments and must answer `set_up?(person)`, true when the
     person has one set up, and `verify(person, code)`, returning
     `:authenticator_app`, `:backup_codes` or nil.
   - `config.parent_controller` — defaults to `"::ApplicationController"`.
     Change it only if door_check's pages should inherit from another host
     controller. That controller must include `DoorCheck::Tracking` and define
     the person and account methods.
   - `config.parent_mailer` — defaults to `"::ApplicationMailer"`. The host
     needs this class, or another named here, for every email door_check
     sends: the sign-in email, the confirmation email, the email that
     confirms a new address, and the notice about that change sent to the
     current address.
   - `config.passkey_domain` — defaults to the host name of each request. Set it
     when passkeys must work across subdomains. Passkeys saved against one
     domain do not work on another, so ask before changing it on an app that
     already has passkeys.
   - `config.locate_ip` — without it, approval requests show the bare IP
     address.
   - `config.stylesheet` — defaults to `"application"`. Set it if the host's
     main stylesheet has another name.
   - `config.head_partial` — a partial path such as `"layouts/door_check_head"`,
     for fonts, a favicon or theme tags the host's own layout adds to its head.
   - `config.authenticator_issuer` — defaults to the name of the host
     application's module, such as `"Shop"` for `Shop::Application`. Set it when
     people should see another name in their authenticator app. Changing it does
     not rename accounts people already added.
   - `config.people_choose_second_step = false` — defaults to true. Set it to
     false when only the app and its accounts' rules decide who is asked for a
     second step. While it is false, no person's saved choice is applied in any
     account, the personal section shows "This app decides when you are asked
     for a second step." in place of its checkbox, and the account section
     shows "This app decides when members are asked for a second step." in
     place of its members checkbox. While it is false, door_check also refuses
     a save of a person's own second-step choice with the first message, and a
     save of the account section that carries the members choice with the
     second. A refused save leaves the earlier value in place. Saved choices
     are kept, and apply again if it is set back to true.
   - `config.sign_up_person` — nil by default, which leaves the sign-up page
     off. Set it when people who have no login yet should create one through
     door_check's sign-up page:
     ```ruby
     config.sign_up_person = lambda do |controller, values|
       user = User.new(name: values[:name], email: values[:email])
       if user.save
         DoorCheck::Result.new(ok: true)
       else
         DoorCheck::Result.new(ok: false, message: user.errors.full_messages.to_sentence)
       end
     end
     ```
     When `password` is offered, the lambda also saves the password:
     ```ruby
     config.sign_up_person = lambda do |controller, values|
       user = User.new(name: values[:name], email: values[:email])
       user.password = values[:password] if values[:sign_in_method] == "password"
       if user.save
         DoorCheck::Result.new(ok: true)
       else
         DoorCheck::Result.new(ok: false, message: user.errors.full_messages.to_sentence)
       end
     end
     ```
     The model and fields are examples. Ask the developer how a new person is
     created and what refuses a sign-up. When `password` is offered, also ask
     how the app saves a password at sign-up and what makes a password
     invalid. door_check calls it as `sign_up_person.call(controller, values)`.
     `values` holds every value the form sent, `name` and `email` among them,
     and every value in the sign-up page's address, such as an invitation
     token. It is read by string or symbol key. The lambda must create the
     person and return a `DoorCheck::Result`: ok when the person was created,
     or refused with the message to show on the page. A person it reports as
     created must be one `find_person_by_email` finds by the address entered.
     - When `find_person_by_email` already finds a person for the address
       entered, door_check never calls `sign_up_person`. Whichever choice the
       visitor made, door_check emails that existing person a sign-in code and
       link and takes the visitor to the email code page. A visitor on the
       password choice is not signed in.
     - When `sign_up_person` returns ok and `find_person_by_email` then finds
       nobody, the page shows "Sign-up could not be finished. Try again in a
       moment.", nobody is signed in and nothing is sent.
     - When `sign_up_person` raises, door_check reports the error to
       `Rails.error` and the page shows "Sign-up could not be finished. Try
       again in a moment.". Nobody is signed in and nothing is sent.
     - The sign-up page is the engine's `new_sign_up` route, at
       `/door_check/sign_up/new` when the engine is mounted at `/door_check`.
       It asks for a name and an email.
     - It answers not found unless `sign_up_person` is set and
       `offered_methods` includes `password`, `email_code`, or both.
     - When both are offered, the page shows two tabs, "Emailed code" and
       "Password", and opens on "Emailed code". Switching tabs does not
       reload the page, and the name and email already typed stay filled in.
       When only one is offered, only that one shows, with no tabs.
     - A link to the page with `sign_in_method=password` in its address opens
       it on the "Password" tab. A refused sign-up reopens the page on the
       tab the visitor chose.
     - `values[:sign_in_method]` carries the visitor's choice on every
       sign-up, `"password"` or `"email_code"`.
     - On the password choice the page also asks for a password, and `values`
       carries it as typed in `values[:password]`. The host saves the
       password. door_check never stores it.
     - An empty password is refused on the page with "Enter a password to sign
       up." before `sign_up_person` is called.
     - After an ok result for the email code choice, door_check finds the
       person with `find_person_by_email`, so that lambda must find the person
       just created. It emails them the sign-in code and link and takes them to
       the email code page. Entering the code signs them in, with `email_code`
       recorded as the session's proof.
     - After an ok result for the password choice, door_check finds the person
       with `find_person_by_email`, signs them in with `sign_in_person`,
       records `password` as the session's proof, and redirects to `/`. No
       sign-in code is sent.
     - After an ok result for the password choice, door_check also emails a
       confirmation link, with the subject "Confirm your email address", to
       the address entered. The link works once and for 24 hours. Opening it
       marks the address confirmed and signs nobody in. A confirmation link
       cannot sign anyone in, and a sign-in link cannot confirm an address.
       A used or expired link shows a page with a "Send a new confirmation
       email" button, which sends a new link to the same address.
     - That button and the settings section's "Send the confirmation email
       again" button count toward the same limit of five requests per person
       in an hour, kept in the cache step 6 checks. A sixth request sends
       nothing and shows a page saying "You asked for the confirmation email
       too many times. Try again later.". A request with no person behind it
       is counted by IP address.
     - When the confirmation email fails to send, door_check reports the
       error to `Rails.error`. The person stays signed in, and the personal
       settings section still offers to send the confirmation email again.
     - The email code choice gets no confirmation email. Using any email code
       or email link, at sign-up or at sign-in, confirms the address it was
       sent to.
     - After a refused result, the page shows the message and keeps the name
       and email that were entered. The password field is left empty.
     - door_check adds `:password` to the host's `config.filter_parameters`
       itself, so the host adds no log filter for the password.
     - The page also shows a required agreement checkbox named `agreement`.
       When it is not ticked, door_check refuses the sign-up on the same page
       with "Tick the agreement to sign up.", keeps the name and email, and
       does not call `sign_up_person`. When it is ticked, `values` carries
       `agreement` as `"1"` with the other values. door_check stores nothing
       about the agreement, so `sign_up_person` must record it wherever the
       host keeps its terms and privacy acceptances.
     - Linking to the page from the host is the develop local's to write.
   - `config.sign_up_agreement_label` — defaults to
     `"I agree to the Terms of Service and Privacy Policy"`. Set it when the
     checkbox should say something else:
     ```ruby
     config.sign_up_agreement_label = "I agree to the Terms of Service and Privacy Policy"
     ```
     Ask the developer what the checkbox should say.
   - `config.sign_up_agreement_links` — defaults to a lambda returning `[]`,
     which shows no links. Set it to show the documents the agreement names as
     links under the checkbox:
     ```ruby
     config.sign_up_agreement_links = lambda do |controller|
       [
         { title: "Terms of Service", url: controller.main_app.terms_path },
         { title: "Privacy Policy", url: controller.main_app.privacy_path }
       ]
     end
     ```
     The titles and routes are examples. Ask the developer which documents to
     link and where each one is. Each hash must carry both `title` and `url`.
     Each link opens in a new tab, so the sign-up page stays open.
   - `config.sign_up_link_on_sign_in = false` — defaults to true. While it is
     true and the sign-up page is on, the email sign-in page shows a "Create an
     account" button under its form that opens the sign-up page. Set it to
     false when people should reach the sign-up page only through links the
     host sends them, such as an invitation. It removes only that button: the
     sign-up page stays on and still opens from any link to it, with the
     values in that link's address passed to `sign_up_person`. It has no
     effect while the sign-up page is off. Ask the developer whether anyone
     may sign up from the sign-in page, or only people the host invites.
   - `config.email_change_confirmed` — nil by default. Set it when people may
     change their sign-in email address. door_check calls it when a person
     opens the link that confirms a new address:
     ```ruby
     config.email_change_confirmed = lambda do |controller, user, email|
       if user.update(email: email)
         DoorCheck::Result.new(ok: true)
       else
         DoorCheck::Result.new(ok: false, message: user.errors.full_messages.to_sentence)
       end
     end
     ```
     The model and field are examples. Ask the developer where the host keeps
     a person's sign-in address and what refuses a new one, such as an
     address another person already uses. door_check calls it as
     `email_change_confirmed.call(controller, person, new_email)`, with the
     person the link was sent for and the address it was sent to.
     - door_check never changes the person's address itself. The lambda must
       save `new_email` where the host keeps it, and return a
       `DoorCheck::Result`: ok when the address was saved, or refused with
       the message to show.
     - After an ok result, door_check marks `new_email` as the person's
       confirmed address and shows a page saying "Your new email address is
       confirmed. Use it to sign in from now on.". Nobody is signed in.
     - After a refused result, door_check shows a page titled "Email address
       not changed" with the result's message, and marks nothing confirmed. A
       refused result with no message shows "Your email address could not be
       changed. Ask for the change again in a moment.".
     - When the lambda raises, door_check reports the error to `Rails.error`
       and shows that same general message. While the setting is unset, every
       link fails this way, so set it before the host offers people a way to
       ask for a change.
     - The link is used up when it is opened, before the lambda is called. A
       link opened a second time, after 24 hours, or after the person
       cancelled the change, shows a page saying it no longer works and to ask
       for the change again, and the lambda is not called. A person refused
       once asks for a new link.
     - Asking for the change and writing the form for it are the develop
       local's work.
   - `config.email_change_cancelled` — nil by default. Set it when the host
     wants to act on a person cancelling a change to their sign-in email
     address, such as recording it or warning an admin:
     ```ruby
     config.email_change_cancelled = lambda do |controller, user, email|
       Rails.logger.info("User #{user.id} cancelled the change to #{email}")
     end
     ```
     The body is an example. Ask the developer what the app should do when a
     person cancels a change they did not ask for. door_check calls it as
     `email_change_cancelled.call(controller, person, new_email)`, with the
     person the change was asked for and the new address that was asked for.
     - When a change is asked for, door_check also emails a notice, with the
       subject "A change to your sign-in email was requested", to the address
       the person answers `email` with. It names the new address and carries
       a "This wasn't me" link. A person with no `email` gets no notice and
       has no link to cancel with.
     - door_check calls the lambda when the person opens that link. Before
       calling it, door_check ends the unused links that confirm the change,
       so the new address can no longer be confirmed. door_check changes no
       address itself.
     - The lambda's return value is ignored. After it returns, door_check
       shows a page titled "Email change cancelled" saying "The change to
       your email address is cancelled. Your email address stays as it
       was.". Nobody is signed in.
     - When the lambda raises, door_check reports the error to `Rails.error`
       and still shows the cancelled page. While the setting is unset, every
       cancel is reported this way, and the change is still cancelled.
     - The link works once and for 24 hours. It also stops working once the
       person opens the link that confirms the change, even when
       `email_change_confirmed` refuses or raises. A link that no longer
       works shows a page titled "Email change not cancelled", and the
       lambda is not called.

9. Ask the developer what the app should hold back from a person whose email
   address is not confirmed, such as sending invitations or changing billing.
   door_check holds nothing back on its own. The host decides, by asking
   door_check whether the person's current address is confirmed:
   ```ruby
   DoorCheck::EmailConfirmation.confirmed?(current_user, current_user.email)
   ```
   `current_user` and `email` are examples. Pass the host's person and the
   address the host holds for them now. The answer is false when the address
   was never confirmed or has changed since. Writing those checks is the
   develop local's work, so hand the answers to it. When the developer wants
   nothing held back, skip this step.

10. Add the tracking and the second-step check to the host's
    `app/controllers/application_controller.rb`, or to the controller named in
    `parent_controller`:
    ```ruby
    class ApplicationController < ActionController::Base
      include DoorCheck::Tracking
      include DoorCheck::EntryCheck

      before_action :door_check_check_entry
    end
    ```
    door_check's own pages skip the check. Ask the developer whether any host
    controller, such as the sign-in page, should also skip it with
    `skip_before_action :door_check_check_entry`. A request with no signed-in
    person always passes the check.

11. Record each sign-in made by the host's own sign-in page. That call is the
    develop local's to write. Hand it to the develop local before the app goes
    live, since a session that was never recorded meets no second-step rule.

12. Place the two settings sections on the host's settings pages:
    ```erb
    <%= render "door_check/settings/sign_in_methods",
               person: current_user,
               account: current_account,
               submit_urls: {
                 own_second_step: own_second_step_settings_path,
                 remove: remove_sign_in_method_settings_path,
                 sign_out_session: sign_out_session_settings_path,
                 remove_trusted_browser: remove_trusted_browser_settings_path
               } %>

    <%= render "door_check/settings/sign_in_rules",
               account: current_account,
               submit_url: sign_in_rules_settings_path %>
    ```
    The route names are examples. Each URL is a host route that takes a `PATCH`.
    The sections send these parameters to them:
    - `own_second_step` receives `second_step_required`.
    - `remove` receives `credential_id`.
    - `sign_out_session` receives `signed_in_session_id`.
    - `remove_trusted_browser` receives `trusted_device_id`.
    - The account section's URL receives `accepted_methods[]`,
      `second_step_required` and `members_choose_second_step`. While
      `people_choose_second_step` is false it does not send
      `members_choose_second_step`.
    - The host action behind the account section's URL must pass
      `members_choose_second_step` on only when the request carries it.
      door_check keeps the account's earlier value when the parameter is
      missing, and refuses the save when it is present while
      `people_choose_second_step` is false.

    The personal section renders its own titled groups, so place it on the page
    without a heading or panel around it:
    - **Sign-in methods** — the person's saved methods, with a button to set up
      an authenticator app, a passkey or new backup codes for each of those
      that `offered_methods` includes. It also shows a "Send the confirmation
      email again" button when door_check holds an address for the person and
      the address the person answers `email` with is not confirmed. That
      covers an address never confirmed and one the host changed after it was
      confirmed. A person whose `email` is blank sees no button. That button
      posts to door_check's own route, so the host adds no route for it. It
      sends a new link to the address the person answers `email` with now, or
      to the address door_check stored at sign-up when the person does not
      answer `email` at all. Opening that link confirms the address it was
      sent to. An earlier link keeps working until it expires. A sixth press
      within an hour sends nothing and shows the "Try again later." page
      described under `sign_up_person`.
    - **Signed-in sessions** — the person's sessions that are still signed in.
    - **Trusted browsers** — shown only when `trusted_device` is offered.
    - **Second step** — the person's own second-step checkbox, or a note in its
      place.

    On a phone-width screen each table shows as a list and the setup buttons
    stack at full width.

    The account section renders its own panel, holding three titled groups and
    one Save button, so place it on the page without a heading or panel around
    it either:
    - **Accepted methods** — a checkbox for each method in `offered_methods`.
      Members enter the account only after using one of the ticked methods.
    - **Second step** — the checkbox that asks members who signed in with only
      a password for a second step before they enter.
    - **Members** — the checkbox that lets a member's own second-step choice
      apply in this account, or, while `people_choose_second_step` is false,
      the note "This app decides when members are asked for a second step." in
      its place.

    Every account starts out letting its members choose their own second step.
    While an account does not, a person's own choice is not applied inside that
    account, and only the account's own rule decides.

    Pass the person's current account as `account:` to the personal section.
    When that account requires a second step, the Second step group shows
    "Your account asks everyone for a second step." above the checkbox or note.
    When that account does not let members choose, the group shows the note
    "Your account decides whether you are asked for a second step." in place of
    the checkbox. A save of the person's own choice in that account is refused
    with the same note, and the person's earlier choice is kept. Leave
    `account:` out only when the host has no accounts, since without it the
    checkbox always shows and no account note appears.

    The controller actions behind those routes are the develop local's to
    write. Ask the developer which settings page each section goes on, and who
    may see the account section.

## Conventions

- After install, boot the app and open the mounted path's second-step page
  while signed in. A boot error naming a sign-in method means a name in
  `offered_methods` is wrong.
- Device approval refreshes the waiting page and the approvals list over Turbo
  Streams, and it expires a waiting request with a background job. The host
  needs Action Cable and an Active Job adapter running for both.
- If the host uses importmap, door_check adds its own pins on boot. Nothing
  needs adding to the host's `config/importmap.rb`.
- After upgrading the gem, run `bin/rails door_check:install:migrations` and
  `bin/rails db:migrate` again to copy any new migrations.
- After upgrading to a door_check with the confirmation email limit, run step 6
  again for each environment.
- Changing `offered_methods` needs an app restart.
- Out of scope: recording a sign-in, reading proofs, checking whether a
  person's address is confirmed, requesting a change of a person's email
  address, linking to door_check's pages, and the actions that change rules,
  end sessions or remove methods.
  Those belong to the develop local.

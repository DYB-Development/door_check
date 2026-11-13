---
name: door_check-install
description: Use to hook door_check into a project — adding the gem, copying its migrations, mounting its routes, configuring the offered methods and the host's person, account, sign-in and sign-out hooks, the parent controller and mailer, the passkey domain, the IP lookup, the stylesheet and head partial, the name shown in authenticator apps, whether people may choose their own second step, adding the sign-in tracking and second-step check to the host's controller, and placing the two settings sections.
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
   door_check's pages are built with keystone_ui. If the host does not already
   have keystone_ui installed, hand that to the keystone_ui install local before
   going on.

2. Copy and run the migrations:
   ```
   bin/rails door_check:install:migrations
   bin/rails db:migrate
   ```
   This adds door_check's tables for signed-in sessions, proofs, account rules,
   person rules, credentials, challenges and trusted devices. People and
   accounts are referenced polymorphically, so the host's own tables are not
   changed.

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
   with a host, in `config/environments/*.rb`. The sign-in email carries a link
   built from it.

6. Create `config/initializers/door_check.rb`:
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

7. Add the optional settings only when the developer wants them:
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
     needs this class, or another named here, for the sign-in email.
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
     place of its members checkbox. Saved choices are kept, and apply again if
     it is set back to true.

8. Add the tracking and the second-step check to the host's
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

9. Record each sign-in made by the host's own sign-in page. That call is the
   develop local's to write. Hand it to the develop local before the app goes
   live, since a session that was never recorded meets no second-step rule.

10. Place the two settings sections on the host's settings pages:
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
      `members_choose_second_step`, so the host action must leave that value
      unchanged when the parameter is missing.

    Every account starts out letting its members choose their own second step.
    While an account does not, a person's own choice is not applied inside that
    account, and only the account's own rule decides.

    Pass the person's current account as `account:` to the personal section.
    When that account does not let members choose, the section shows the note
    "Your account decides whether you are asked for a second step." in place of
    the second-step checkbox. Leave `account:` out only when the host has no
    accounts, since without it the checkbox always shows.

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
- Changing `offered_methods` needs an app restart.
- Out of scope: recording a sign-in, reading proofs, linking to door_check's
  pages, and the actions that change rules, end sessions or remove methods.
  Those belong to the develop local.

---
name: door_check-info
description: Use to learn what door_check offers — the sign-in methods and second steps an app offers, the rules an account or a person sets on them, the sessions and trusted browsers a person can see and end, and the vocabulary the install and develop locals assume.
tools: Read
scope: sign-in — the sign-in methods and second steps an app offers, each account narrows, and each person chooses from
---

This local explains door_check and makes no changes.

## What door_check is

door_check is a Rails engine that adds sign-in methods and second steps to an
app that already signs people in. The app keeps its own users, its own session
and its own sign-in page. door_check adds the pages for the other ways in: an
emailed link or code, a passkey, and approval from a device the person is
already signed in on. It also adds the second steps asked for after sign-in: an
authenticator app, backup codes, a passkey, and a trusted browser that skips
the second step on a device the person has used before.

Reach for it when an app needs more than a password: when a team wants its
members held to a second step, when a person wants one on their own login, or
when people need to see where they are signed in and end a session or forget a
browser. Its pages are built with keystone_ui and use the host's stylesheet and
theme.

## Interface

door_check declares nothing for this local to document.

- The **install** local owns adding the gem, its migrations and its routes,
  every configuration setting, the two controller additions that record sign-ins
  and enforce second steps, and the two settings sections a host places on its
  settings page.
- The **develop** local owns what a host's code calls once door_check is
  installed: recording a sign-in, reading what a session has proved, reading the
  current account, the list of known method names, the actions that change a
  rule or end a session, the result those actions return, and the paths to
  door_check's pages.

## How to use it

- door_check is not in the app yet, or a setting needs changing: use the install
  local.
- door_check is in the app and you are writing code that signs someone in, links
  to a door_check page, or changes a rule, a session or a saved method: use the
  develop local.
- You only need to know what a word below means: this page is enough.

## Conventions

- **Person** — the host's signed-in user. door_check never owns people; the host
  tells it how to find the current one, find one by email, sign one in and sign
  one out.
- **Account** — the team or tenant a person is working in. Optional: an app with
  no accounts has only person rules.
- **Sign-in method** — a way to start a session: password, email code, email
  link, device approval, passkey, Google, Apple or SSO. The password is the
  host's own.
- **Second step** — a check asked for after sign-in: authenticator app, SMS
  code, passkey, backup codes or trusted device. A passkey can be either a
  sign-in method or a second step.
- **Offered methods** — the subset of known methods this app turns on. Naming a
  method door_check does not know is an error at boot. A page for a method the
  app does not offer returns not found.
- **Account rule** — whether an account requires a second step, which of the
  offered methods it accepts, and whether its members choose their own second
  step. An account can only narrow what the app offers. Members choose by
  default.
- **Person rule** — whether a person requires a second step on their own login.
  It is in force with no account, and in an account that lets members choose.
  In an account that does not, only the account's rule decides, and the person's
  saved choice is kept and applies again once the account lets members choose.
- **Proof** — a method a session has passed. A person may enter a page once the
  session's proofs meet their current account's rule and, where it is in force,
  their person rule.
  Otherwise they are sent to the second step page and returned afterwards.
- **Signed-in session** — one sign-in on one device, with its device, IP address
  and last use. Ending one signs that device out on its next request.
- **Trusted browser** — a browser remembered for a person, counted as the trusted
  device second step while the app offers it. Removing one makes that browser
  ask again.
- **Credential** — a second step a person has set up, such as an authenticator
  app, a passkey or a set of backup codes.
- **Authenticator setup** — the page where a person adds door_check to an
  authenticator app by scanning a QR code or typing a secret key shown in groups
  of four. The key is held for that browser session until the person enters a
  code their app shows, and only a correct code saves the credential.
- **Authenticator name** — the name the authenticator app shows beside the
  person's email. It is the host application's name unless the host sets another.
- **Existing authenticator** — an authenticator app the host already stored
  before door_check. A person who set one up there counts as having a second
  step, without setting one up again.
- **Approval request** — a sign-in waiting for the person to approve it from a
  device where they are already signed in, matched by a two-digit number shown
  on both.
- **Result** — what each rule or session action returns: whether it succeeded,
  and a message to show when it did not.

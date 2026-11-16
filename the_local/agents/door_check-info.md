---
name: door_check-info
description: Use to learn what door_check offers — the sign-in methods and second steps an app offers, the rules an account or a person sets on them, the sessions and trusted browsers a person can see and end, the sign-up page with its sign-in choice and agreement checkbox, email address confirmation with its confirmation email and resend button, and the vocabulary the install and develop locals assume.
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
  every configuration setting, including the callable that creates a person
  from the sign-up page and the sign-up page's agreement label and links, the two controller additions that record sign-ins
  and enforce second steps, and the two settings sections a host places on its
  settings page.
- The **develop** local owns what a host's code calls once door_check is
  installed: recording a sign-in, reading what a session has proved, reading the
  current account, whether a person's email address is confirmed, the list of
  known method names, the actions that change a
  rule or end a session, the result those actions return, and the paths to
  door_check's pages, the sign-up page among them.

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
- **Sign-up page** — door_check's page where a person with no login enters a
  name and an email and chooses how to sign in. The host's sign-up callable
  creates the person from those values and any values in the page's address,
  such as an invitation token, and answers ok or refused with a message. The
  page is off, and answers not found, unless the host sets the callable and
  offers email codes, passwords, or both. A person the callable reports as
  created must be one the host's find-by-email lookup finds.
- **Sign-up with an existing address** — when the host's find-by-email lookup
  already finds a person for the address entered, door_check never calls the
  sign-up callable. Whichever choice the visitor made, door_check emails that
  existing person a sign-in code and link and takes the visitor to the email
  code page. A visitor on the password choice is not signed in.
- **Unfinished sign-up** — when the callable answers ok but the find-by-email
  lookup then finds nobody, or when the callable raises, the page shows
  "Sign-up could not be finished. Try again in a moment.". Nobody is signed in
  and nothing is sent. An error the callable raised is reported to
  `Rails.error`.
- **Sign-in choice at sign-up** — when the app offers both email codes and
  passwords, the sign-up page shows a tab for each and opens on the emailed
  code. When it offers one, only that one shows. The callable receives the
  choice as `sign_in_method`, `"password"` or `"email_code"`, which may be
  missing when the person kept the first choice.
- **Email code sign-up** — on ok, door_check emails a sign-in code and link and
  takes the person to the email code page, and entering the code signs them in
  by email code.
- **Password sign-up** — the page also asks for a password, and the callable
  receives it as typed. The host saves the password, and door_check never
  stores it. An empty password is refused with "Enter a password to sign up."
  before the callable is called. On ok, door_check signs the person in with
  the host's sign-in, records password as the proof, and goes to the app's
  home page, with no code sent. door_check adds the password to the host's
  log filter itself. door_check then sends a confirmation email to the
  address entered. When that email fails to send, the failure is reported to
  `Rails.error`, the person stays signed in, and the resend button still
  shows.
- **Confirmation email** — the email sent after a password sign-up, with the
  subject "Confirm your email address" and one link. The link works once and
  for 24 hours. Opening it marks the address confirmed and signs nobody in. A
  confirmation link cannot sign anyone in, and a sign-in link cannot confirm
  an address. A used or expired link shows a page with a "Send a new
  confirmation email" button, which sends a new link to the same address.
- **Confirmed address** — an email address the person has proved they can
  read. Opening a confirmation link confirms it, and so does using any email
  code or email link, at sign-up or at sign-in. An email code sign-up sends no
  confirmation email, since entering the code confirms the address. People
  who existed before door_check kept confirmations read as not confirmed
  until they use an email code or link.
- **Confirmed check** — the host asks door_check whether a person is confirmed
  by passing the person and the address the host holds for them now. The
  answer is true only when that address was confirmed. Case and surrounding
  spaces are ignored. A person who has changed their address since reads as
  not confirmed. door_check holds nothing back from a person who is not
  confirmed. The host decides what to limit, such as sending invitations or
  changing billing.
- **Resend button** — "Send the confirmation email again", shown in the
  personal settings section's Sign-in methods group to a signed-in person
  whose address is waiting to be confirmed. It sends a new link to the address
  door_check stored at sign-up. The earlier link keeps working until it
  expires.
- **Refused sign-up** — the page shows the callable's message, keeps the name
  and email, and leaves the password empty.
- **Sign-up agreement** — the required checkbox on the sign-up page. Its label
  is "I agree to the Terms of Service and Privacy Policy" unless the host sets
  another, and the host may list documents, each a title and an address, shown
  as links under it. When it is not ticked, the page refuses the sign-up with
  "Tick the agreement to sign up.", keeps the name and email, and does not call
  the host's sign-up callable. When it is ticked, the callable receives
  `agreement` as `"1"` with the other values, and the host's own terms and
  privacy records keep it. door_check stores nothing about the agreement.
- **Second step** — a check asked for after sign-in: authenticator app, SMS
  code, passkey, backup codes or trusted device. A passkey can be either a
  sign-in method or a second step.
- **Offered methods** — the subset of known methods this app turns on. Naming a
  method door_check does not know is an error at boot. A page for a method the
  app does not offer returns not found.
- **People choosing their own second step** — an app-wide switch, on by
  default. When the app turns it off, no person rule is in force anywhere, and
  only account rules decide when a second step is asked for.
- **Account rule** — whether an account requires a second step, which of the
  offered methods it accepts, and whether its members choose their own second
  step. An account can only narrow what the app offers. Members choose by
  default, and only while the app lets people choose.
- **Refused account rule save** — saving an account rule that accepts a method
  the app does not offer is refused with "Pick only methods this app offers."
  Saving one that sets whether members choose, while the app does not let people
  choose, is refused with "This app decides when members are asked for a second
  step." A refused save changes nothing, and the account keeps its earlier rule.
- **Person rule** — whether a person requires a second step on their own login.
  It is in force only while the app lets people choose, and then with no
  account or in an account that lets members choose. Elsewhere only the
  account's rule decides, and the person's saved choice is kept and applies
  again once both the app and the account let them choose.
- **Refused person rule save** — saving a person rule where the person may not
  choose is refused. The message is "This app decides when you are asked for a
  second step." when the app does not let people choose, and "Your account
  decides whether you are asked for a second step." when the person's account
  does not let members choose. A refused save changes nothing, and the person
  keeps their earlier choice.
- **Personal settings section** — the section where a person sees their saved
  methods, signed-in sessions and trusted browsers, and sets their person rule.
  It shows four titled groups, each in its own panel: Sign-in methods, with the
  buttons to add one and the resend button while the person's address waits to
  be confirmed; Signed-in sessions; Trusted browsers, left out when the
  app does not offer trusted browsers; and Second step. On a phone each table
  shows as a list and the add buttons stack at full width.
- **Second step group** — the part of the personal settings section that holds
  the person rule's checkbox. When the person's current account requires a
  second step, it shows the note "Your account asks everyone for a second
  step." above the rest. When the app does not let people choose, it shows the
  note "This app decides when you are asked for a second step." in place of the
  checkbox. When the person's current account does not let members choose, it
  shows the note "Your account decides whether you are asked for a second
  step." instead.
- **Account settings section** — the section where an account's rule is set,
  in one panel with one Save button. It shows three titled groups, each with a
  line saying what ticking it does. Accepted methods lists every offered method,
  and members enter the account only after using one of the ticked methods.
  Second step holds the checkbox that makes members who signed in with only a
  password take a second step before they enter. Members holds the checkbox that
  lets a member's own second-step choice apply in this account. When the app
  does not let people choose, the Members group shows the note "This app
  decides when members are asked for a second step." in place of its checkbox
  and line.
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

---
name: keystone_ui-info
description: Use to learn what keystone_ui offers — its UI components for pages, forms, tables, navigation and dashboards, its look, colour and theme model, and the vocabulary the install and develop locals assume.
tools: Read
scope: UI — pages, forms, tables, navigation, dashboards
---

This local explains keystone_ui and says which local does the work. It changes
nothing and gives no steps.

## What keystone_ui is

keystone_ui is a Rails engine gem that supplies a host app's UI as view helpers
built on ViewComponent. Screens are built from named pieces — page shells,
sections, panels, grids, forms and fields, buttons and rows of buttons, search dropdowns, data tables, navigation, cards,
badges, status dots, value lists, stat tiles, charts, timelines, funnels, goal buckets, pipelines, breakdowns, code blocks,
text diffs and info buttons —
instead of hand-written ERB and Tailwind. Every class the UI renders lives in the
gem, so two pages built from the same helpers cannot disagree about spacing,
colour or dark-mode treatment, and a change to a component reaches every page
that uses it.

Reach for it whenever you build or change a screen in an app that has it
installed. It is mobile-first, because these apps are often shown in a native
web view: small screens get a mobile header and a bottom tab bar, and from the
`lg:` breakpoint up the app gets a full navigation bar or sidebar.

## Interface

This local declares no commands. The working surfaces belong to the other two:

- **Getting the gem into a host app** — the install generator, the
  configuration block, the theme and look attributes on the layout, the palette,
  registered looks, the navigation groups, the text diff's line limit, and the
  suppliers for trails, themes,
  looks, the current tab and saved preferences → **`keystone_ui-install`**.
- **Building screens with it** — which helper renders what, the keywords each
  takes, and how they nest → **`keystone_ui-develop`**.

## How to use it

One decision: is keystone_ui set up in the app?

- No, or the setup is out of date → **`keystone_ui-install`**.
- Yes, and there is a screen to build or edit, or a question about which piece
  fits → **`keystone_ui-develop`**. Do not hand-write ERB or Tailwind for UI it
  covers.

## Conventions

- **Helpers, not classes.** Every piece of UI is a view helper prefixed `ui_`.
  Components sit under the `Keystone::Ui` namespace, but a host app does not
  name a component class. The one class a host does name is the table column
  value object, which is passed as an argument and renders nothing.
- **Containers take blocks, leaves take keywords.** Page shells, sections,
  panels, grids, forms and tables wrap a block. A button, badge, field, stat or
  bucket is set entirely by keyword arguments. The navigation bar takes named
  slots, and a section takes one named slot for its aside.
- **Options are symbols.** Appearance is chosen by name, such as `variant:`,
  `size:` or `padding:`, and each component accepts its own set. Most raise on a
  symbol they do not know, so a wrong guess fails at render time.
- **Numbers and text are different inputs.** Progress bars, funnels, buckets
  and timelines do arithmetic, so they take numbers, and a bucket raises on
  `"9,000"`. A timeline takes each entry's times and works out every duration,
  bar position and its axis from them. A
  breakdown, a calculation and a toned figure take already-formatted text, show
  it as written and add nothing up.
- **Timelines.** A timeline entry is one try at a step: a label, a start time,
  an end time, and optionally the time it was queued and whether it failed.
  Entries sharing a label are drawn as several bars on one row, in the order
  given. The row's duration is the time of each try added together, so the
  gaps between tries are not counted, and a row with more than one try adds the
  number of tries after it, such as `· 3 att.`. A duration under ten seconds is
  written with one decimal, such as `8.2s`, and a longer one in whole hours,
  minutes and seconds, such as `1m 5s`. Queued time is drawn as its own
  segment before the bar, and a failed try is marked failed both in colour and
  for screen readers. An entry can be marked waiting, for a try that has not
  started running: its bar runs from its start to the end of the axis in the
  waiting colour, and its row shows the word `waiting` in the warning tone in
  place of a duration, with no running dot. The axis
  runs from the earliest queued or start time of any entry to the latest end
  or start time. An entry with no end time is still running: its bar runs to
  the latest end or start time of any entry, and its row shows a status dot that screen readers read
  as "Running". Every bar is drawn at least a small visible width, so a try
  that took no time still shows. An entry with no start time, or one that ends
  before it starts, raises `ArgumentError` naming its label. A timeline with no
  entries shows a message saying there are no steps. By default each row shows
  its label and duration on one line with the bar below, and the axis under the
  rows shows only `0s` and the total duration. A timeline can be drawn one line
  per row instead: from `sm:` up each row holds its label, its bar and its
  duration side by side, every row's bar has the same width, and a long label is
  cut off with an ellipsis. Below `sm:` it falls back to the default layout:
  each row shows its full label, wrapped when long, and its duration above its
  bar, and the axis under the rows shows `0s` and the last mark. In that layout the axis, drawn above the first row, shows marks at the smallest round time step
  that covers the run in six intervals or fewer, and the axis ends at the last mark rather than at the latest
  time, so bars are placed against that longer axis. An entry can carry an address, and then its bar is a link to it whose
  name screen readers announce is the entry's label, and the row's label links
  to the address of the last entry in that row that has one. An entry can be
  marked selected, and the row holding it is drawn in the same tint as a data
  table's current row and announced to screen readers as the current item.
- **Tab rows.** A tab switcher's tabs are either labels switched in the
  browser or links to addresses, with the chosen link drawn as the current
  tab. Label tabs can each hold a panel on the same page, and choosing a tab
  shows its panel and hides the others, so values typed into fields are kept,
  and the fields of a hidden panel are disabled, so a required field on a
  hidden panel does not stop the form being sent. A panel can be narrower than
  its content, so a wide panel does not widen the page on a phone. A link tab
  can carry a count shown after its label, and a count of zero is shown only
  when the tab asks for it. A tab switcher can hold a summary, drawn above the
  tabs on a wider screen and below them on a phone. The row is centred
  on wider screens, or starts at the left edge when asked. It can be drawn as
  plain tabs, as outlined pills such as a row of filters, or as tabs on a line
  with the chosen one underlined. On a phone every row stays on one line and
  scrolls sideways.
- **Bar chart groups.** A bar chart's bars can be put in groups, such as one
  group per version of what produced them. Groups count from oldest to newest
  in the order they first appear. Every bar of a group shares one tone, and
  the tones run from grey for the oldest to the accent for the newest, with
  no two of five or fewer groups sharing one. Past five, every group older
  than the newest four is grey. Only the first bar of each group carries a
  label under the axis, starting at that bar's left edge, apart from the
  newest group's label, which ends at the chart's right edge. A bar chart can
  also be drawn as a short strip with no value axis and no grid lines, only a
  baseline, and its bars nearly touching.
- **Value lists.** A value list shows labelled values, each a label and a value
  with an optional note, a fallback shown when the value is empty, a total
  marking and a check mark for a value that is right. By default each pair is a
  row with its label beside its value and a line between rows. A value list can
  lay its pairs in columns instead: one column on a phone and two from `sm:` up,
  each label in small text directly above its value, a long value wrapping
  inside its own column, and no line between pairs.
- **Section headers.** A section's header holds its title and optional
  subtitle, then an optional action link and action menu. A section can also
  carry an aside, a short piece of text or a badge drawn in the header's note
  style at the right end of the title line, before the action and the menu.
  The aside never breaks in the middle of a word, and on wider screens a long
  title wraps beside it while it keeps its full width. Below `sm:` the aside
  takes a line of its own under the title and the actions. A section with no title draws no header, so its aside is not shown.
- **Going back.** A form or show page shell needs a way back: a back link, a
  trail of earlier pages shown as breadcrumbs, or a trail the app supplies for
  the request. A nav tab's own page passes an empty trail and shows no back
  link. A page with none of these raises `KeystoneUi::MissingBackLink`, and a
  trail link missing a label or an address raises `KeystoneUi::IncompleteTrail`.
- **Navigation.** The app declares navigation groups, each a label and its tabs,
  and each tab a key, label, address and permission check. A tab can also be
  declared on its own, outside any group, and is then drawn as a single link
  with no menu or group label. A tab can carry a count, and a count above zero
  is shown as a badge after its label, as a bottom tab bar item's count is
  shown over its icon. Tabs the user may
  not see are left out, and a group left with no tabs is left out. A saved
  preference can place the navigation as a top bar or a left or right sidebar
  and set the order of groups and tabs. A supplier names the current tab, which
  is marked active with its group. A declaration with an empty group, a tab with
  no label or address, or two tabs sharing a key stops the app at boot with
  `KeystoneUi::NavigationCheck::Error`.
- **Saved table layouts.** A data table given a key reads the layout saved under
  it: which hideable columns to hide and their order. With a save address, a
  "Columns" menu lets the user change it. A locked first column stays in view
  while the table scrolls sideways and is never hidden or moved.
- **Row detail.** A data table can give each row more to show than its
  columns. That detail sits in a hidden row under its row, across every column,
  and clicking the row or its caret button opens and closes it. Links, buttons
  and the action menu inside the row work without opening it. A row with no
  detail does not open, and an open row stays open through a Turbo morph.
- **Search dropdowns.** A search dropdown picks one record by its id from
  matches the host serves. As the user types, it requests the host's search
  address with the text as `q` and expects JSON back: a list of matches, each
  with an `id` and a `label`. Picking a match submits its id under the field's
  name. When the dropdown offers a choice to enter a new record, picking it
  submits an empty id and shows the new record's fields the page placed inside
  the dropdown, and picking a match afterwards hides them again. The arrow keys
  move through the list, Enter picks, and Escape closes it.
- **Buttons.** A button with an address is a link, or a small form when its
  HTTP method is anything other than a plain visit. A button with no address
  is a form button, which can carry a name and value, start hidden, or be
  disabled so it cannot be pressed.
- **Button rows.** A button row lays out buttons side by side and wraps them
  onto further lines when they run out of room. Below `sm:` each button in it
  is at least a phone's tap height, and a button that sends a request fills its
  share of the row like a link does. A row can give each button an equal share
  of its width, keeping each label on one line, so the row wraps only when a
  label no longer fits. It can do that on a phone only, leaving each button
  the width of its label on a wider screen.
- **Review cards.** A review card shows one item someone reviews, such as
  one of several variants compared side by side. A header line holds a short
  id at the left and a score or status at the right, coloured by tone, above
  a title, body text, an optional call-to-action line and an optional line of
  short details with a divider above it. An optional finding note is drawn
  in the warning style, and the card's edge is then drawn in the warning
  style too. An optional row of buttons gives each button an equal share.
  A compact form cuts the body text to one line with an ellipsis and leaves
  out the call-to-action line and the details line, for a phone. A review card grid sets the cards three across
  on a desktop and one per row on a phone, where each button is at least a
  phone's tap height.
- **Confirmation.** A button can carry a confirmation question, and the
  browser asks it before following the link or sending the form. Nothing is
  sent when the user cancels.
- **A page's main action on a phone.** A page header can name one main action:
  a label, an address, an optional HTTP method and an optional confirmation
  question. The header shows it as a button and also publishes it to the
  layout. Below `sm:` the layout can show it again as a plus icon in the top
  bar, or as a full-width button in a bar fixed to the bottom of the screen,
  above the bottom tab bar when the page has one. The bottom bar asks the
  header's confirmation question before sending, and the plus icon does not.
  The page leaves room under its last content so the bar does not cover it.
  A header can mark its action as belonging at the bottom, and then hides its
  own button below `sm:` so the action is not shown twice. Both forms show
  nothing when the header names no action, and both are hidden inside a
  Hotwire Native web view and in print.
- **Compact stat cards.** A stat card can be drawn compact, a small tile with
  an extra small label and a smaller value, its change or note beside the
  value, for a small grid of figures inside a panel.
- **Unequal grid columns.** A grid goes up to the `xl:` breakpoint, and a
  two-column grid can make its first or its second column wider, three parts
  to two.
- **Normal-case notes.** A caption can be a small muted line in the case it
  was written, holding links, and a page header's subtitle can use a
  fixed-width font.
- **A decision bar.** A decision bar is one form holding an optional note
  field, several secondary buttons and one primary button, and the button
  pressed tells the app which decision was made. On a wider screen it is a
  panel with all of them on one line that wraps, and an optional hint line
  under them. On a phone it is a bar fixed to the bottom of the screen, above
  the bottom tab bar when the page has one, with the primary button at full
  width above a row of the secondary buttons in equal shares, a long label
  wrapping inside its button, and with no note field or hint. The width at
  which it switches between the two can be moved from `sm:` to `md:` or `lg:`. Each secondary button can have a shorter label on a phone, be
  shown on a phone only, and take another place in the phone row. The page leaves room under its last content so the bar does
  not cover it. Unlike the main action's bottom bar, it stays shown inside a
  Hotwire Native web view.
- **Action menus.** Each action is a label, an address and an HTTP method. A
  plain visit is a link, and any other method is a button, so an action that
  changes data is never a bare link. A delete asks for confirmation by default.
- **Status states.** A badge and a status dot read one list of five states:
  neutral, success, danger, warning and info. A state added to that list is
  accepted by both, so the two never disagree about which states exist. A badge
  shows its label as text. A status dot shows only its state's colour, for
  places with no room for text, and its label is read only by screen readers.
  Neither accepts a state outside the list: a status dot raises `ArgumentError`
  naming the states it expects, and a badge raises `KeyError` when it renders.
- **Text diffs.** A text diff compares two texts line by line and shows them
  side by side, stacked on a phone, in the code block's look. Lines the two
  share sit on the same row, a line only the first text has is marked removed
  with a minus, a line only the second has is marked added with a plus, the
  other side shows a blank row beside either one, and each side numbers its own
  lines. On a phone the first text's column sits above the second's. It
  compares whole lines, so a line with one word changed shows as one line
  removed and one added. Windows and Unix line endings compare as equal. Two
  identical texts show a notice saying they are the same above the columns.
  When the two texts together hold more lines than the host's line limit, 2,000
  by default, it does not compare them: it lines them up by position with no
  marks or signs, and the notice says they are too long to compare.
  With its one-column option it shows both texts in one column instead, the
  same at every screen width: a shared line once, a removed line at its place
  in the first text and an added line at its place in the second, each marked
  and signed, with no line numbers. Too long to compare, that column lists the
  first text and then the second, unmarked.
- **Semantic colour.** The themed hue is `accent-*` and the themed neutrals are
  `surface-*`, CSS custom properties whose defaults (blue and zinc) come from
  the keystone_ui-styles gem. Retheming changes those values, not the
  components.
- **Looks.** A look is one CSS file setting keystone_ui-styles' `--ks-`
  variables for radius, font, weight, border, spacing and colour, each colour
  with a `-dark` partner. Components render `ks-` classes that read them, and
  their own Tailwind constants hold only layout, size and behaviour. Looks can
  be registered by name, and the page's `html` tag carries `data-look` for the
  supplied look or the default, when that name is registered.
- **Themes.** Light, dark, system and custom. The mode comes from the user's
  cookie, then a mode another gem supplies, then light. System leaves the page
  to follow the operating system, and custom marks the page for a palette
  another gem defines, which the theme toggle does not offer.
- **Static Tailwind classes.** Class names are never interpolated, so Tailwind's
  scanner finds them. Sizes that depend on data, such as a progress bar's
  width, use an inline style. The host needs tailwindcss-rails v4+.
- **Interactivity is Stimulus.** Dropdowns, search dropdowns, modals, tab
  switchers, the column picker, table row detail, info buttons, charts, copy
  buttons and the theme toggle ship as
  Stimulus controllers, so a host writes no JavaScript. Components that post,
  such as the column picker and the pipeline, post to endpoints the host or
  another gem owns.
- Ruby >= 3.2, ViewComponent >= 2.0 and < 5, keystone_ui-styles >= 0.42.0.

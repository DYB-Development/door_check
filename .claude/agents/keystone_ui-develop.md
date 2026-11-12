---
name: keystone_ui-develop
description: Use PROACTIVELY for building or editing screens in a Rails app that has keystone_ui — page shells with Back links and breadcrumbs, forms and fields, a search field that picks a record or enters a new one, data tables with saved columns, desktop navigation, sidebars and bottom tabs, action menus for a record's Edit and Delete, dashboards with stat cards, charts, funnels and goal buckets, amounts shown in green or red as a gain or loss, pictures held to half the screen, info buttons and breakdowns, marketing sections, a light/dark theme switch — MUST BE USED instead of hand-writing ERB and Tailwind for UI.
tools: Bash, Read, Write, Edit, Grep
scope: UI — pages, forms, tables, navigation, dashboards
---

This local builds screens by composing keystone_ui's `ui_*` view helpers in ERB.
It always works the same way: pick the page shell, fill it with the helpers that
match the content, and write no Tailwind classes of its own.

## What keystone_ui is

keystone_ui is a Rails engine that supplies an app's UI as view helpers. Each
helper renders one named piece — a page shell, a section, a form field, a data
table, navigation, a stat card, a chart — with its styling and dark-mode
treatment owned by the gem, so two screens built from the same helpers cannot
drift apart. It is mobile-first, because these apps are often shown in a native
web view: several helpers render only below or only from the `lg:` breakpoint.

Fire on any request to build or change a screen, view, form, table, navigation
or dashboard in an app that has keystone_ui installed. If the `ui_*` helpers are
not available in the app yet, that is `keystone_ui-install`'s job.

## Interface

- `ui_page` — the outer wrapper of a screen, holding the page's content.
- `ui_form_page` — marks a screen as a form screen and gives it its title, Back link and breadcrumbs.
- `ui_show_page` — marks a screen as a detail screen and gives it its Back link and breadcrumbs.
- `ui_page_header` — the title of a page, with optional badges beside it and a control and action menu on its right.
- `ui_breadcrumbs` — a line of links to the pages above the current one, shown from `lg:` up.
- `ui_section` — a titled block of content with an optional link and action menu in its header.
- `ui_grid` — a responsive grid with a column count per breakpoint.
- `ui_panel` — a bordered card surface holding any content.
- `ui_card_link` — a panel that is one link as a whole.
- `ui_card` — a fixed card of title, summary and call-to-action link.
- `ui_navbar` — a navigation bar with named slots for desktop and mobile.
- `ui_navigation` — draws the app's declared navigation groups as a top bar or a sidebar around the page content.
- `ui_nav_item` — one desktop navigation link.
- `ui_nav_dropdown` — a navbar dropdown menu.
- `ui_bottom_nav` — the mobile bottom tab bar.
- `ui_bottom_nav_item` — one tab in the bottom tab bar.
- `ui_mobile_header` — a mobile back arrow and a title beside it.
- `ui_mobile_actions` — an ellipsis menu of actions shown only below `lg:`.
- `ui_mobile_action` — a plus icon link to the action a screen's page header publishes, for the phone top bar.
- `ui_action_menu` — an ellipsis menu of actions shown at every screen size.
- `ui_action_menu_item` — one action in an action menu, as a link or a button sending a method.
- `ui_settings_link` — a full-width settings row with a chevron.
- `ui_theme_toggle` — Light, Dark and System buttons that switch and remember the page's theme.
- `ui_form` — the form element wrapping a form's fields.
- `ui_form_field` — a labelled input, textarea, checkbox or select with hint and error text.
- `ui_input` — a bare styled input with no label.
- `ui_textarea` — a bare styled textarea with no label.
- `ui_select` — a bare styled select with no label.
- `ui_multi_select` — a dropdown of checkboxes posting every checked value.
- `ui_search_select` — a form field that searches the app as a person types and submits the id of the record they pick.
- `ui_file_upload` — a file drop zone with selected-file feedback.
- `ui_color_picker` — a colour swatch that writes a hex value into a hidden input.
- `ui_radio_card` — a selectable card backed by a radio input.
- `ui_checkbox_row` — a checkbox with its label and hint, toggled by a tap anywhere on the row.
- `ui_sortable_list` — a list of rows dragged into a new order, submitted with the form it sits in.
- `ui_option_card` — a radio whose visible body is whatever its block renders.
- `ui_data_table` — a table of records with links, row actions, sorting, hideable columns and the viewer's own row marked.
- `Keystone::Ui::Column` — a table column with options a `{ key: "Label" }` hash cannot carry.
- `ui_column_picker` — a Columns menu that saves which columns are hidden and their order to an app endpoint.
- `ui_button` — a link or a button styled as a button, or a button sending a POST, PATCH or DELETE request.
- `ui_badge` — a coloured pill holding a short label.
- `ui_figure` — one amount as inline text, coloured as a gain or a loss.
- `ui_picture` — an image never taller than half the screen, optionally opening its full-size file.
- `ui_heading` — a heading at one of three sizes, with an optional short note on its right.
- `ui_caption` — small uppercase muted text placed above a title or a figure.
- `ui_paragraph` — a paragraph of running text.
- `ui_value_list` — rows of a label and its value, such as a ledger or a byline.
- `ui_alert` — a banner message, optionally dismissible.
- `ui_link_list` — a list of links, each row with a label, an optional subtitle, badge and value, and a chevron.
- `ui_empty_state` — what a list or section shows when it has nothing in it, with an optional message and action.
- `ui_progress` — a labelled progress bar.
- `ui_stat_card` — a single metric tile with optional change, link and info button.
- `ui_copy_button` — a button that copies text to the clipboard.
- `ui_code` — a block of code with an optional caption.
- `ui_disclosure` — a native expandable section with a clickable summary.
- `ui_calculation` — the steps behind a figure, closed under a summary row.
- `ui_info` — an inline info button showing a summary, and optional detail, in floating panels.
- `ui_breakdown` — a list of amounts ending in their total.
- `ui_accordion` — a stack of question-and-answer rows that expand independently.
- `ui_tab_switcher` — a row of tabs that reports which one was selected.
- `ui_modal` — a hidden dialog the app's own code opens.
- `ui_swipe_deck` — a stack of cards accepted or rejected by button or swipe.
- `ui_chart_card` — a titled card holding a chart.
- `ui_line_chart` — a line chart with one line per series, over labels or dates.
- `ui_bar_chart` — a bar chart drawn on the server, which needs no JavaScript and prints.
- `ui_funnel` — a conversion funnel drawn as bars or one joined shape.
- `ui_bucket` — an upright container filled toward a goal.
- `ui_bucket_series` — a wrapping row of buckets.
- `ui_pipeline` — a staged flow diagram with buttons and breakable links that post to the app.
- `ui_hero` — a marketing hero with title, call-to-action buttons and an aside.
- `ui_cta_banner` — a marketing banner holding call-to-action buttons.
- `ui_feature_grid` — a responsive grid of feature cards.

## How to use it

Every entry point is a view helper called from ERB, apart from
`Keystone::Ui::Column`. Keywords with defaults are optional and the rest are
required. A symbol option outside the listed values raises at render time, with
two exceptions: `ui_page`'s `padding:` treats any value other than `:none` as
`:standard`, and a `ui_pipeline` box's `accent:` falls back to `:muted`.

1. Confirm the helpers are available in the app. If they are not, stop and hand
   off to `keystone_ui-install`, and do not hand-write the markup meanwhile.

2. Find the closest existing screen in `app/views/` and read it. Match its
   composition before inventing one, since that screen is the house style.

3. Pick the page shell.

   - A form screen → `ui_form_page`, then `ui_page` holding the form.
   - A detail screen → `ui_show_page`, then `ui_page` holding `ui_page_header`
     and the details.
   - Anything else → `ui_page`, with `ui_page_header` for the desktop title.

   ```erb
   <%= ui_form_page(title: "New quote", back_url: quotes_path) %>
   <%= ui_page(max_width: :md) do %>
     <%= ui_form(action: quotes_path) do %>
       ...
     <% end %>
   <% end %>
   ```

   - `ui_page(max_width: :full, padding: :standard, top_offset: nil, class: nil)`
     takes a block. `max_width:` is `:sm` `:md` `:lg` `:xl` `:full`,
     `padding:` is `:standard` or `:none`, and `top_offset:` is `:sm` `:md`
     `:lg` `:xl` to clear a fixed navbar. At its top, above the block, it
     renders what an earlier `ui_form_page` or `ui_show_page` on the same screen
     handed it: the "Back" link, then the breadcrumbs, then the form page's
     title.
   - `ui_form_page(title:, back_url: nil, subtitle: nil, trail: nil)` renders
     nothing where it is called. It publishes the title and back URL for the
     navbar's mobile header, and hands `ui_page` a "Back" link to `back_url`
     shown from `lg:` up, then the title and subtitle shown from `md:` up.
   - `ui_show_page(title:, back_url: nil, subtitle: nil, trail: nil)` renders
     nothing where it is called. It publishes the title, subtitle and back URL
     for the navbar, and hands `ui_page` the "Back" link. It shows no title, so
     put `ui_page_header` inside the `ui_page` block.
   - Call the shell before `ui_page` and outside its block, or the "Back" link,
     breadcrumbs and title do not appear. Never add a second back link or
     button to a shell's screen.
   - `trail:` is `[[label, href], ...]` from the top level down. A non-empty
     trail adds breadcrumbs under the "Back" link, ending with `title`
     unlinked, shown from `lg:` up. With no `trail:`, the shell uses the trail
     the app supplies for the request, if it supplies one. With no
     `back_url:`, the back URL is the `href` of the trail's last link. A
     `trail:` or `back_url:` passed to the shell always wins over the supplied
     one.
   - `trail: []` marks a page a navigation tab opens directly. It shows no
     "Back" link and no breadcrumbs, and with no `back_url:` it publishes no
     back URL, so the mobile header shows no back arrow.
   - With no `back_url:`, no trail from either place, or a trail whose last
     link has no `href`, rendering raises `KeystoneUi::MissingBackLink` naming
     the page's title. A trail with any link whose label or `href` is `nil` or
     blank raises `KeystoneUi::IncompleteTrail` naming the page's title, even
     when `back_url:` is passed.
   - Check whether the app's keystone_ui initializer sets a `trail_supplier`.
     If it does, a screen whose supplied trail is right passes neither `trail:`
     nor `back_url:`. If it does not, every form and detail screen passes
     `back_url:` or `trail:`. Setting up a supplier is `keystone_ui-install`'s
     job.
   - Ask the developer whether a screen shows breadcrumbs and which parent
     screens its trail names. Ask which screens a navigation tab opens
     directly, since those pass `trail: []`.
   - `ui_page_header(title:, subtitle: nil, action_url: nil, action_label: "Add new", action_method: nil, badges: [], menu: [], class: nil)`
     takes a block yielding the header. Call
     `header.action { ... }` in the block to place a control on its right.
     `action_url:` declares the screen's main action. It publishes that URL and
     label for `ui_mobile_action` to pick up, and with no `action` block the
     header draws them as a button. An `action` block is drawn alone when both
     are given. `action_method:`, such as `:post`, makes the main action send
     that method: the header's button and `ui_mobile_action`'s icon become
     forms posting to `action_url:`.
   - `badges:` is `[{ label:, variant: }, ...]`, each drawn as a `ui_badge`
     beside the title, with `variant:` taking the badge's values. `menu:` is
     `[{ label:, href:, method: }, ...]`, each hash taking the keywords of
     `ui_action_menu_item`, drawn in an action menu beside the actions. Put a
     record's Edit and Delete in `menu:` on its detail screen.
   - Below `sm:` a header given no badges and no menu is hidden, even with an
     action. A header given badges or a menu is shown there with its badges,
     actions and menu, and hides its title when the page holds
     `ui_mobile_header`'s title. Its action then shows below `sm:` beside
     `ui_mobile_action`'s plus icon, so ask the developer whether a screen
     with both keeps both.
   - `ui_breadcrumbs(trail:, current: nil)` renders `trail:` as links separated
     by `›`, then `current:` unlinked and marked as the current page, shown
     only from `lg:` up. On a form or detail screen pass `trail:` to the shell
     instead of calling it.
   - Below `lg:` the back link comes from `ui_mobile_header`, rendered by the
     navbar from the title and back URL the shells publish. If the layout does
     not render `ui_mobile_header` from that context, ask the developer whether
     to wire it before adding more screens that depend on it.

4. Lay out the body. Each of these takes a block and they nest.

   - `ui_section(title: nil, subtitle: nil, action: nil, menu: [], spacing: :md, class: nil)`
     — `action:` is `{ label:, href: }` and renders a right-aligned link.
     `menu:` is `[{ label:, href:, method: }, ...]`, each hash taking the
     keywords of `ui_action_menu_item`, and renders an action menu at the right
     of the header. `spacing:` is `:sm` `:md` `:lg`. The header, with its
     `action:` and `menu:`, renders only when `title:` is given.
   - `ui_grid(cols: { default: 1 }, gap: :md, gap_x: nil, gap_y: nil)` —
     `cols:` maps `:default` `:sm` `:md` `:lg` to a count from 1 to 12, such as
     `{ default: 1, md: 3 }`. `gap:` is `:sm` `:md` `:lg` `:xl`, and passing
     `gap_x:` or `gap_y:` replaces `gap:` entirely.
   - `ui_panel(padding: :md, radius: :lg, shadow: true)` — `padding:` is `:sm`
     `:md` `:lg` and `radius:` is `:md` `:lg` `:xl`.
   - `ui_card_link(href:, padding: :md, shadow: true)` — `padding:` is `:sm`
     `:md` `:lg`.
   - `ui_card(title:, summary:, link:, cta: "Read more", edge_to_edge: false, class: nil)`
     takes no block. `edge_to_edge: true` drops the side border and corner
     rounding below `sm:` so the card spans the full width on mobile.

5. Wire navigation in the layout.

   Every navigation component is left off a printed page, so a printed page or
   a PDF holds only the page's content.

   - `ui_navigation` takes no keywords and a block holding the page content, so
     it goes around `yield`. It draws the tabs the app declares with
     `config.navigation_group` as a top bar of menus from `lg:` up, then the
     content, and below `lg:` it draws only the content. It leaves out tabs
     whose permission check fails and groups with no tab left. A tab declared
     outside any group with `config.navigation_tab` is drawn as a plain link
     in the top bar and as a plain tab with no group label in the sidebar,
     which does not open or close.
   - Inside its block, `navigation.with_logo do ... end` puts the app's logo at
     the left of the top bar, and `navigation.with_menus do ... end` puts menus
     such as the account menu at its right, so the layout draws no second bar.
     With no group left, it draws only the content unless a logo or menus are
     set, in which case the top bar holds just those.
   - When the preference supplied for `:navigation` holds
     `{ "placement" => "left" }` or `"right"`, it draws a sidebar on that side
     from `lg:` up instead, with each group's label above its tabs, the logo at
     its top and the menus at its bottom. A menu there opens in place: the
     `data-dropdown-target="menu"` panel inside a `data-controller="dropdown"`
     element drops onto its own line below its button inside the sidebar, even
     when the app's own CSS positions it absolutely, as long as that CSS sits
     in a layer below Tailwind's utilities such as `components`. A closed
     panel (the `hidden` class) stays invisible and out of the tab order but
     still counts toward the sidebar's width, so opening a menu never
     changes the sidebar's width. Any other
     placement draws the top bar, whose menus still open as dropdowns. An `"order"` list of `{ "group" => label, "tabs" => [tab key strings] }`
     entries draws the named groups and tabs first, in that order, then the
     rest in declared order, ignoring names no longer declared.
   - When the app sets `config.current_tab_supplier`, the tab whose key it
     returns and that tab's group show as active in either placement. A `nil`
     key, a key no declared tab has, or no supplier marks nothing.
   - Check whether the app's initializer declares navigation groups before
     adding desktop tabs by hand. Declaring groups, the placement and order
     preference, and the current tab supplier are `keystone_ui-install`'s job.
   - `ui_navbar(sticky: true)` takes a block yielding the navbar. Fill its
     slots: `logo`, `desktop_links`, `desktop_right`, `mobile_left`,
     `mobile_center`, `mobile_right`. Desktop slots are hidden below `lg:` and
     mobile slots from `lg:` up. `desktop_right` renders only when
     `desktop_links` is also filled.
   - `ui_navbar(hide_logo_on_mobile: true)` hides the `logo` slot below `lg:`
     and keeps it from `lg:` up, for a page that shows its own title in
     `ui_mobile_header`. It defaults to `false`, which keeps the logo at every
     width.
   - `ui_nav_item(label:, href:, active: false, count: nil)` is one desktop
     link, with `count:` shown in a badge after the label when above zero.
     `ui_nav_dropdown(title:, area:, active: false)` takes a block holding the
     menu links.
   - `ui_bottom_nav` takes no keywords and a block of
     `ui_bottom_nav_item(label:, href:, icon:, active: false, count: nil)` calls,
     where `icon:` is a raw SVG string and `count:` above zero shows in a badge
     over the icon. The bar is hidden from `lg:` up and inside a
     Hotwire Native web view.
   - `ui_mobile_header(title:, back_url:, subtitle: nil)` is hidden from `lg:`
     up and goes in the navbar's `mobile_left` slot. `back_url:` must be
     passed, and `nil` renders the title with no back arrow. The title and
     subtitle sit between the arrow and the right-side controls, start at the
     left, and end in an ellipsis when too long. In `ui_navbar`, controls that
     leave less than 6rem for the title move to a second row under it. In a
     hand-written top bar, make the header a direct child of the bar's flex
     row, and add `max-lg:has-[.ks-mobile-header-title]:flex-wrap` to the bar if
     its controls can fill its width.
   - `ui_mobile_action` takes no keywords and no block, and goes in the top
     bar's right side, such as the navbar's `mobile_right` slot. It draws a plus
     icon linking to the `action_url:` a screen gives `ui_page_header`, named
     with its `action_label:`, and draws nothing when the screen gives none. It
     is hidden from `sm:` up, where the page header shows the action, and inside
     a Hotwire Native web view, so give native users another way to reach the
     action, such as `ui_mobile_actions`. The layout must also write the
     `hotwire-native` class on `<html>` and declare that Tailwind variant.
   - `ui_settings_link(label:, href:)` renders one settings row.
   - `ui_theme_toggle` takes no keywords and no block. Its buttons switch the
     theme at once and store the choice in the `keystone_theme` cookie for a
     year, and System follows the operating system. The button for the current
     mode renders pressed, and none is pressed when the mode is a custom
     palette supplied by another gem. Ask the developer where it goes, such as
     a settings screen, the navbar's `desktop_right` or a mobile menu. It stays
     correct across page loads and Turbo visits only when the layout's `<html`
     tag carries the theme attributes and the gem's Stimulus controllers are
     registered. If the tag carries nothing for the theme, stop and hand that
     part to `keystone_ui-install`.

6. Build forms.

   - `ui_form(action:, method: :post, multipart: false, data: nil)` takes a
     block. `method:` may be `:patch`, `:put` or `:delete`, sent as Rails
     expects. Set `multipart: true` when the form holds a file upload.
   - `ui_form_field(attribute:, label: nil, type: :text, required: false, hint: nil, placeholder: nil, min: nil, max: nil, step: nil, value: nil, options: [], errors: [], include_blank: nil, disabled: false, suggestions: [], autofocus: false, autocomplete: nil, autocapitalize: nil, inputmode: nil)`
     is the default way to render a field. `type:` is `:text` `:number`
     `:email` `:password` `:date` `:datetime` `:textarea` `:checkbox` `:select`.
   - A `:datetime` field is a `datetime-local` input for a date and a time of
     day. A `Time` or `DateTime` given as `value:` is written as
     `YYYY-MM-DDTHH:MM`, and a string is used as given.
   - `attribute:` is used as the input's `name` as given, so pass the full
     param name, such as `"quote[title]"`, and pass `label:` whenever it is a
     nested name. `label:` defaults to the attribute with underscores turned to
     spaces and the first letter capitalized. `errors:` is an array of message
     strings.
   - A `:select` takes `options:` as `[[label, value], ...]`, and `value:`
     picks the selected option. A select that is not required gets a leading
     empty option, worded by `include_blank:` or left blank without it, so
     never add an empty choice to `options:` as well.
   - A `:checkbox` renders its label beside the box, submits `"0"` unchecked
     and `"1"` checked, and is checked when `value:` is `"1"`.
   - `suggestions:` is an array of strings the browser offers while typing, and
     the user can still type any value. It applies to `:text` `:number`
     `:email` `:password` `:date` `:datetime` and is ignored by the other types. Its list
     is identified by `attribute:`, so two fields with suggestions on one
     screen need different `attribute:` values.
   - The field's label is tied to its input, textarea, select or checkbox
     through an `id` built from `attribute:`, so tapping the label focuses the
     input, or ticks and unticks the checkbox, and a screen reader reads the
     label. `"player[email]"` gets the id
     `player-email`, so two fields on one screen need different `attribute:`
     values.
   - `required: true` marks the label with an asterisk and, on a `:text`
     `:number` `:email` `:password` `:date` `:datetime` field, sets the
     input's `required` attribute so the browser will not send the form with
     it empty.
   - `autofocus: true` puts the cursor in the input when the page opens. Give
     it to one field per page at most.
   - `autocomplete:`, `autocapitalize:` and `inputmode:` are written onto the
     input as given, such as `autocomplete: "email"`, `autocapitalize: "none"`
     and `inputmode: "numeric"`. They let a phone suggest a saved value, stop
     capitalizing the first letter, and open the right keyboard.
   - `autofocus:`, `autocomplete:`, `autocapitalize:` and `inputmode:` apply to
     the same types as `suggestions:` and are ignored by `:textarea`
     `:checkbox` and `:select`.
   - A value that must be one of a fixed list is a `:select`, and a free value
     with common choices is a text field with `suggestions:`. Ask the developer
     which a field is and which values it offers.
   - `ui_input(name:, type: :text, value: nil, placeholder: nil, disabled: false, min: nil, max: nil, step: nil, autofocus: false, autocomplete: nil, autocapitalize: nil, inputmode: nil, required: false)`
     takes `:text` `:number` `:email` `:password` `:date` `:datetime`. Its
     `autofocus:` `autocomplete:` `autocapitalize:` and `inputmode:` work as on
     `ui_form_field`, and `required: true` sets the `required` attribute.
     `ui_textarea(name:, value: nil, rows: 3, placeholder: nil, disabled: false)`
     and `ui_select(name:, options: [], selected: nil, include_blank: nil, disabled: false)`
     are the bare forms of the other two. Use them only where a label does not
     belong.
   - `ui_multi_select(name:, label:, options:, selected: [])` posts every
     checked value under `name` as given, so pass an array name such as
     `"status[]"`. `options:` is `[[label, value], ...]` and `selected:` is the
     values to check. Its button reads "All <label>" with nothing checked and
     "N selected" otherwise.
   - `ui_search_select(name:, label:, url:, selected_id: nil, selected_label: nil, new_label: nil)`
     is one field inside a `ui_form`, for picking one record from more than a
     select can list. Each keystroke sends `GET url?q=<typed text>` with
     `Accept: application/json`, and the app answers with a JSON array of
     `{ "id": ..., "label": ... }` objects in the order to list them. Labels
     are shown as plain text. Picking a match by click, or by the arrow keys
     and Enter, puts its id in a hidden input named `name` and its label in
     the field. Escape closes the list.
   - The app owns the search endpoint: the route, which records it searches,
     how it matches the typed text, how many matches it returns, and which
     records the current user may see. Ask the developer for each, and scope
     the query to the current account.
   - `selected_id:` and `selected_label:` open the field with a record already
     chosen, such as on an edit screen, so the form submits that id unchanged
     when nothing else is picked.
   - Typing without picking leaves the hidden id as it was, so the form submits
     the last picked id, or `selected_id:`, whatever the field shows.
   - `new_label:` adds a last choice, such as "Enter a new address", shown in
     the list after each search. Picking it clears the hidden id and shows the
     block passed to the helper, which holds the fields for a new record such
     as `ui_form_field` calls. Picking a match afterwards hides them again.
   - The block's fields are submitted whether shown or hidden, so the app's
     controller treats a blank id as "create from the new fields" and a present
     id as "use that record and ignore the new fields". Ask the developer
     whether a person may enter a new record, and what `new_label:` says.
   - `ui_file_upload(name:, label: nil, accept: nil, multiple: false, hint: nil)`
     needs the enclosing form to be multipart.
   - `ui_color_picker(name:, value: "#000000", label: nil)` writes the chosen
     hex value into a hidden input named `name`.
   - `ui_radio_card(name:, value:, label:, hint: nil, info: nil, checked: false)`
     and `ui_checkbox_row(name:, value:, label:, hint: nil, info: nil, checked: false)`
     share `hint:` and `info:`. `hint:` is a line always shown under the label.
     `info:` adds an info button beside the label, named "About <label>" for
     screen readers, that shows the text in a panel below while hovered and
     toggles it when tapped. Text every reader needs goes in `hint:` and text
     only some want goes in `info:`, so ask the developer which is which.
   - A checked `ui_checkbox_row` submits `value` under `name`, an unchecked one
     submits nothing, and rows sharing an array name such as `"shown[]"`
     submit the checked values as a list.
   - `ui_sortable_list(name:, label:, rows:)` is one field inside a `ui_form`,
     for putting a short list in order. `rows:` is an array of
     `{ id:, label: }` hashes, `label:` names the list for screen readers, and
     `name:` names a hidden field in each row, so pass an array name such as
     `"order[]"` and a different one for each list on a page. The form submits
     the ids in the order shown, and the list makes no request of its own. A
     row is dragged by its handle, or moved with its Move up and Move down
     buttons. Without JavaScript the form submits the starting order.
   - `ui_option_card(name:, value:, selected: false, input_data: {}, label_data: {})`
     takes a block rendering the card's body. `input_data:` and `label_data:`
     become `data-*` attributes on the input and the label.

7. Put the actions on a record, such as Edit and Delete, in an action menu
   rather than a row of buttons: `menu:` on the `ui_page_header` or `ui_section` showing the record,
   `table.actions` for a table row, or `ui_action_menu` anywhere else.

   - `ui_action_menu` takes no keywords and a block of `ui_action_menu_item`
     calls, and shows at every screen size. `ui_mobile_actions` takes the same
     block and is hidden from `lg:` up, so use it only for actions that
     desktop reaches some other way.
   - `ui_action_menu_item(label:, href:, method: :get, confirm: nil)` is a link
     with `method: :get`. Any other method renders a button in its own small
     form sending that method, so never place such an item inside a `ui_form`
     block.
   - `confirm:` is a question Turbo asks before the item sends. With no
     `confirm:`, a `:delete` item asks "<label> this? This cannot be undone."
     and every other method sends without asking. A `:get` item ignores
     `confirm:`. Ask the developer whether a `:post`, `:patch` or `:put` action
     needs a question.

8. Build tables.

   - `ui_data_table(items:, columns:, empty_message: nil, sort: nil, sort_direction: nil, sort_url: nil, hidden_columns: [], key: nil, group_by: nil, group_totals: {}, total: nil, current_row: nil, phone_list: false)`
     takes a block yielding the table. `items:` are records or hashes, and a
     cell's value is the column key called on the item, or `item[key]`.
     `group_by:` lists rows under heading rows named by that key's value,
     `group_totals:` (`{ "Group name" => { column_key => value } }`) puts
     subtotals in each heading row, and `total:` (`{ column_key => value }`)
     ends the table with a total row. Pass every subtotal and total already
     calculated. `align: :start` or `:end` on a `Column` aligns it left or right.
   - `phone_list: true` shows the table as a list below `sm:`. The heading
     row is hidden there, each row is one item, and each cell sits on its own
     line under its column's heading, starting at the left and wrapping. A
     row's links, badges, detail button and action menu stay in its item, and
     group subtotals and totals after the first carry their headings. Sorting
     is not reachable below `sm:`, since the sort links are in the heading row.
     From `sm:` up the table is unchanged, and a table without it is unchanged
     at every width. It is chosen table by table, so ask the developer which
     tables show as a list on a phone.
   - `columns:` takes `{ key: "Label" }` hashes when every column is plain.
     Switch the whole set to `Keystone::Ui::Column` objects once one column
     needs an option.
   - `Keystone::Ui::Column.new(key, header_text, mobile_hidden: false, sortable: false, hideable: false, locked: false, align: nil, wrap: false)`
     — `mobile_hidden:` hides the column below `sm:`, `sortable:` gives it a
     sort header, and `hideable:` lets it be hidden and moved.
     `wrap: true` lets long text in the column's cells wrap onto more lines
     inside the cell instead of widening the table, every other cell keeps its
     text on one line, and headings are unchanged.
     `locked: true` on the first column keeps it in view while the rest scrolls
     sideways, a locked column that is not first renders as an ordinary one,
     and a locked column is never hideable. Ask the developer whether a wide
     table locks its first column.
   - In the block, `table.link(:column_key) { |item| url }` turns a column's
     cells into links, and `table.actions { |item| ... }` adds a right-aligned
     actions column whose block holds only `ui_action_menu_item` calls. With no
     actions column, the last column is right-aligned, so put a column of
     amounts last.
   - `table.row_colour { |item| ... }` tints a whole row. The block returns
     `:danger`, `:warning`, `:success`, `:info` or `nil` for each item. A named
     colour tints every cell of that row in the same colour as the badge of
     that name, `nil` leaves the row plain, and any other value raises
     `KeyError`. Colour alone does not reach every reader, so also make the
     row's meaning readable as text in the row, such as a status badge or a
     word in a cell.
   - `table.row_detail { |item| ... }` gives a row detail that opens under
     it. The block is ERB, so it may hold helpers such as `ui_value_list`.
     What it renders is drawn in a hidden row under the item's row, in one
     unstyled cell across every column, and a block that renders `nil` or
     nothing but whitespace gives that row no detail and no caret. A row with
     detail opens and closes when it is clicked or when Enter or Space is
     pressed on the caret button at the start of its first cell. A click on a
     link, button, form control, label or `summary` in the row does what it
     always does and leaves the row as it is, so the action menu and linked
     cells still work. An open row stays open through a Turbo refresh morph.
     Use it when a table should show a few columns and still hold more about
     each row, rather than adding columns or a second table, and ask the
     developer what the detail shows.
   - Sorting needs all three of `sort:` (the current column key),
     `sort_direction:` (`:asc` or `:desc`) and `sort_url:` (a lambda taking
     `(column_key, direction)` and returning a URL). Headers then render as
     links that flip direction.
   - `current_row:` takes the item whose row is the viewer's own, such as
     their entry on a scoreboard or leaderboard. That row carries the
     `ks-table-row-current` class, which keystone_ui-styles colours, and
     `aria-current="true"`, so a screen reader announces it. The item
     is compared with `==` and only the first equal row is marked, so pass the
     same record or an equal hash. Use it instead of a "You" badge in a cell.
   - `hidden_columns:` is the table's default layout and drops only hideable
     columns. The declared order is the default order.
   - For a table whose columns a user chooses and keeps, check whether the
     app's initializer sets a `preference_supplier`. If it does, pass `key:`
     and the default `hidden_columns:`, and add no `ui_column_picker`. A saved
     `"hidden_columns"` list replaces `hidden_columns:`, an empty saved list
     shows every column, and a saved `"column_order"` places the hideable
     columns in that order while other columns keep their place. When the
     supplier returns a save address, the table renders its own Columns menu
     above it. Ask the developer which key names the table, which columns are
     hideable, and which are hidden by default.
   - If the app sets no supplier, ask the developer whether to use
     `ui_column_picker` with an endpoint the app owns, or to hand setting up a
     supplier to `keystone_ui-install`.
   - `ui_column_picker(columns:, hidden_columns: [], save_url: nil)` lists the
     hideable columns in the order given, each with a checkbox and up and down
     buttons. Pass it the columns in the order the table shows them and the
     same hidden keys. When the menu closes with a change, it sends one
     `PATCH save_url` with a CSRF token and the JSON
     `{ "hidden_columns": [...], "column_order": [...] }`, then reloads.
     `column_order` lists every hideable key. The app's endpoint must store both
     lists and answer with a success status. On an error status or no
     connection the menu shows "Your column changes were not saved." and puts
     its boxes and order back. It does not reorder the table, so the app passes
     both the table and the picker their columns in the saved order.

9. Show content and status.

   - `ui_button(label:, href: nil, method: :get, variant: :primary, size: :md, full_width: false, type: :submit, data: nil)`
     renders a link with `href:` and a button without it. `variant:` is
     `:primary` `:secondary` `:danger`, `size:` is `:sm` `:md` `:lg`, and
     `type:` applies only to the button.
   - With `href:` and `method:` `:post` `:patch` `:put` or `:delete`, it
     renders a button inside its own small form that sends that request to
     `href:` when tapped. Do not write a form around it. It cannot sit inside
     another form, since a form cannot hold a form. `type:` and `data:` are not
     used on it.
   - `full_width: true` makes the button as wide as its row at every screen
     width, and for a button sending a request its form too. Use it for large
     choices stacked down a phone screen.
   - `ui_picture(src:, alt:, full_size_url: nil)` shows an image centred and
     never taller than half the visible screen, so what follows it stays in
     view. `alt:` is the text read out in place of the image. With
     `full_size_url:`, tapping the picture opens that address in a new tab, so
     pass `src:` a smaller version and `full_size_url:` the original file. Ask
     the developer which version of an uploaded image each address points at.
   - `ui_badge(label:, variant: :neutral, class: nil)` — `variant:` is
     `:neutral` `:success` `:danger` `:warning` `:info`.
   - `ui_alert(message:, type: :info, title: nil, dismissible: false, class: nil)`
     — `type:` is `:info` `:success` `:warning` `:error`, and `dismissible: true`
     adds a close button.
   - `ui_link_list(rows:)` — each row is `{ label:, href:, subtitle: nil,
     badge: nil, value: nil }`, and `badge:` takes `ui_badge`'s `{ label:, variant: }`.
     Use it for a list of records that each open their own page, in place of a
     hand-written `<ul>` of links.
   - `ui_empty_state(title:, message: nil, action: nil)` — `action:` is
     `{ label:, href: }` and draws a secondary button. Use it in place of a bare
     "Nothing yet" paragraph wherever a list or section can be empty.
   - `ui_progress(value:, max:, label: nil)` shows `value / max` as a percent,
     rounded and capped at 100.
   - `ui_copy_button(text:, label: "Copy", success_message: "Copied!", error_message: "Failed!")`.
   - `ui_code(language: nil, caption: nil)` takes a block holding the code.
     `caption:` is a strip above it and `language:` sets the `language-*`
     class for a highlighter.
   - `ui_disclosure(open: false)` takes a block yielding the component. Fill
     its `summary` slot with the header, and the rest of the block is the body.
   - `ui_accordion(items: [])` — `items:` is `[{ question:, answer: }, ...]`.
   - `ui_heading(text:, size: :md, note: nil)` — `size:` is `:sm` `:md` `:lg`,
     and `note:` puts a short muted note at the right end of the heading's row.
   - `ui_caption(text:)` shows small uppercase muted text above a title or a figure.
   - `ui_paragraph(text:)` shows running text.
   - `ui_value_list(rows:, align: :start)` — each row is `{ label:, value: }`
     with optional `note:`, `total: true` and `fallback:`, shown when the value
     is `nil` or empty. `align: :end` pushes values to the right, as in a ledger.

10. Explain figures.

    - `ui_stat_card(label:, value:, variant: :neutral, suffix: nil, definition: nil, calculation: nil, change: nil, href: nil, note: nil, plain: false, fallback: nil)`
      — `variant:` is `:neutral` `:success` `:danger` `:warning` `:info` and
      colours the value. `change:` is a signed number shown as `▲ 4.2%` in
      green, `▼` in red, or plain at zero. `href:` links the value only, so
      never wrap a stat card in `ui_card_link`. `definition:` and
      `calculation:` add an info button whose panel shows while hovered or
      focused and toggles when tapped.
    - `ui_figure(text:, tone: :neutral)` prints one amount inline. `tone:`
      `:neutral` uses the surrounding text colour, `:success` green and
      `:danger` red, and any other symbol raises `KeyError`. Its output can go
      anywhere a string is shown, such as a table cell. Use it, not a badge or
      a colour class, for a gain or a loss, and ask the developer which amounts
      are coloured and what counts as a gain.
    - `ui_calculation(groups:, summary: "How this is worked out")` shows the
      steps behind a figure, closed under a row reading `summary:`. `groups:`
      is `[{ title:, lines: [{ label:, working:, result: }, ...] }, ...]`.
      `title:` is optional, a group without `lines:` raises `KeyError`, and a
      line with another key raises `ArgumentError`. Put it directly under the
      figure it explains, and ask the developer which steps a reader needs.
    - `ui_info(summary:)` is an info button beside the thing it explains,
      named "More about this" for screen readers. `summary:` is a short line
      shown while hovered. With a block, a tap toggles a wider panel holding
      the block, and the summary stays hover-only. With no block, a tap
      toggles the summary. A click elsewhere closes the detail and scrolling
      closes both. The panels are not cut off by a table or other clipping
      container. The block may hold only text and inline elements, such as a
      `ui_breakdown`, never a `<div>`, list or table. Pass plain sentences with
      no line breaks.
    - `ui_breakdown(lines:, total:)` — `lines:` is `[{ amount:, label: }, ...]`
      and `total:` is one `{ amount:, label: }`. It adds nothing up, so
      compute the total. It renders inline, so it can sit in a `ui_info` block.
      Ask the developer which amounts it lists and how the summary is worded.
    - Every value these print is shown as given, so format numbers, currency
      and minus signs before passing them.

11. Draw charts and analytics.

    - `ui_chart_card(title:, height: :md)` takes a block holding a chart, with
      `height:` `:sm` `:md` `:lg`.
    - `ui_bar_chart(bars:, show_values: false)` — `bars:` is
      `[{ label:, value:, shaded: }, ...]`, where `shaded: true` draws a bar
      faded. It is drawn on the server as an SVG, so use it, not
      `ui_line_chart`, for a chart that must print or show without JavaScript.
    - `ui_line_chart(series:, labels: nil, dates: nil, height: :md)` —
      `series:` is `[{ name:, data:, color:, dashed: }, ...]`, where `color:`
      is a CSS colour and `dashed: true` is optional. Pass exactly one of
      `labels:` and `dates:`, or it raises `ArgumentError`. `labels:` are
      strings spaced evenly. `dates:` are `Date`, `Time` or `DateTime` values,
      one per value, placed by day and read as dates such as "Oct 2, 2026",
      with the time of day dropped. Use `dates:` for calendar days and never
      format dates into `labels:`. A day with no value leaves a wider gap, so
      ask the developer whether a missing day is left out or passed as zero.
    - `ui_funnel(steps:, shape: :bars)` — `steps:` is
      `[{ label:, value:, color: }, ...]` in order. Each width is the value's
      share of the first step's value, and the percent between two steps is
      the second divided by the first. Colours run `:accent` `:sky` `:violet`
      `:amber` `:rose` and repeat, and `color:` picks one of those or raises.
      `:bars` draws one bar per step with a `↓ N%` caption between bars.
      `:joined` draws one shape with a narrowing band holding the percent
      between blocks. Any other `shape:` raises `ArgumentError`. Ask the
      developer which shape they want.
    - `ui_bucket(goal:, actual:, label: nil, over: :success)` shows the label,
      `goal`, the container, `actual` and the percent reached. `goal` and
      `actual` must be numbers, so a string or `nil` raises `ArgumentError`.
      They print as Ruby prints them, so convert a `BigDecimal` with `to_i` or
      `to_f`. The percent is not capped and is 0 for a zero goal. Over the goal
      the fill turns green with `over: :success` or amber with `over: :warning`.
    - `ui_bucket_series(buckets:)` takes an array of hashes with the keywords
      of `ui_bucket`, such as `[{ goal: 10, actual: 7, label: "Mon" }, ...]`.
    - `ui_pipeline(title:, boxes:, links:, subtitle: nil)` — `boxes:` is
      `[{ label:, count:, accent:, action: }, ...]`, with `accent:` one of
      `:amber` `:emerald` `:danger` `:muted`, and `action:` is
      `{ url:, label:, params:, variant: }`, a button that POSTs `params` to
      `url`. `links:` has one fewer entry than `boxes:`, each
      `{ url:, params:, broken: }`, a toggle between two boxes that POSTs to
      flip its state.

12. Add interactive pieces whose outcome the app owns.

    - `ui_modal(title:, size: :md)` takes a block holding the body, with
      `size:` `:sm` `:md` `:lg` `:xl`. It renders with the `hidden` class and
      closes on its close button and on a backdrop click. Nothing in the gem
      opens it, so the app's code removes `hidden`.
    - `ui_tab_switcher(tabs:)` takes an array of label strings and a block
      rendered below the tabs. The first tab is active on load, and a click
      sends a `tab-switcher:change` event with the clicked index. Showing and
      hiding the panels is the app's code.
    - `ui_tab_switcher(tabs:)` also takes link tabs, an array of hashes
      `{ label:, href:, current: }`. Each is drawn as a link to its `href`, the
      one with `current: true` is drawn active with `aria-current="page"`, and
      following a tab is a Turbo visit that replaces the history entry. The
      app reads the chosen tab from its params and draws only that tab's
      content in the block.
    - `ui_swipe_deck(items:, empty_title: "All done!", empty_subtitle: nil)`
      takes a block yielding the deck, where `deck.item { |item| ... }` renders
      one card's face. Accepting sends a bubbling `swipe-deck:complete` event
      and rejecting sends `swipe-deck:skip`. Both carry `detail.itemId` (the
      item's `id`, or its position) and `detail.card`, and `complete` carries
      `detail.value` from an input marked `data-swipe-deck-value`, or `null`.
    - For these, the pipeline's URLs, the column picker's save URL and the
      search select's search URL, do not
      invent routes or how the outcome is stored. Ask the developer, then
      build what they pick.

13. Build marketing sections.

    - `ui_hero(title:, subtitle: nil, badge: nil, layout: :split,
      height: :screen)` takes a block holding the call-to-action buttons and
      yields the component, so its `aside` slot can hold an image or panel.
      `layout:` is `:split` or `:centered`. `height: :screen` keeps the hero at
      least the full screen height, and `height: :content` draws it only as
      tall as its content and its padding, for a page with more sections
      after it.
    - `ui_cta_banner(title:, subtitle: nil)` takes a block holding the
      buttons.
    - `ui_feature_grid(title:, features:, subtitle: nil)` — `features:` is
      `[{ icon:, title:, description: }, ...]`, where `icon:` is a raw SVG or
      HTML string.

14. Read back what you wrote and delete every Tailwind class and inline `style`
    you added. If the result still needs one, a different helper fits, so go
    back to the steps above. Bring it to the developer only if no helper fits.

    If a piece renders unstyled where it should not — an info button that
    shows nothing, a breakdown in one run of text, a `:success` or `:danger`
    figure in plain colour, a joined funnel with no band, a locked column the
    others show through, a Columns menu with no greyed name for a hidden
    column, or a table row whose caret does not open its detail — the app's Stimulus controllers or keystone_ui-styles version are
    out of date. Stop and hand that part to `keystone_ui-install`, and add no
    classes to fix it.

## Conventions

- **Helpers only.** Call `ui_*` helpers from ERB and never name a component
  class in the app. `Keystone::Ui::Column` is the one exception, since it is
  passed as an argument and renders nothing.
- **Never hand-write Tailwind for something a helper covers.** The gem owns
  spacing, colour, borders, radius, shadow and dark mode.
- **Never restyle a helper from outside** — no wrapper that overrides its
  padding or width, and no CSS aimed at its markup. Choose a different option
  instead, or say the helper does not fit.
- **`class:` needs the developer's approval.** `ui_page`, `ui_section`,
  `ui_page_header`, `ui_card`, `ui_alert` and `ui_badge` append it to their
  outer element, where it can override anything the gem sets. Name the class
  and the reason and wait for a yes.
- **Semantic colour only.** Themed colour is `accent-*` and `surface-*`. Never
  write a literal colour into a view.
- **Options are per helper.** A button's `variant:` and a badge's `variant:`
  take different symbols, so use the values listed for that helper.
- **Containers take blocks, leaves take keywords.** The data table, page header
  and swipe deck render only what is registered through the object they yield,
  so anything else emitted in their block is dropped.
- **Check both screen sizes.** Page headers with no badges or menu, mobile headers, mobile actions,
  bottom navigation, breadcrumbs and `ui_navigation`'s bars render on one side
  of `lg:` or `sm:` only, so a screen needs both treatments.
- Out of scope: installing or upgrading the gem, its configuration, the theme
  attributes on the layout, and the palette, which belong to
  `keystone_ui-install`. A new UI piece belongs in the gem, so raise it with
  the developer rather than building it in the app's views.

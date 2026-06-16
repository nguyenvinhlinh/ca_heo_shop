# Task 042-00 - Implement real admin customer index

Date: 2026-06-16

## Goal

Update the admin customer index page at:

```text
/admin/customers
```

so it lists real customer records from the database instead of mock data.

The LiveView module for this page should be:

```elixir
CaHeoShopWeb.Admin.CustomerLive
```

The admin customer index should support:

```text
real customer listing
enabled / disabled filter
search by fullname and email
pagination
page size selection
mock View order button
mock Enable / Disable button
```

Also extend customer user data with:

```text
phone_number
is_customer_enabled
```

`is_customer_enabled` allows the admin to disable spam or abusive customer accounts.

When a customer is disabled, that customer must not be able to log in.

## Naming decision

Use this database field name consistently:

```text
is_customer_enabled
```

Do not create both:

```text
is_customer_activated
is_customer_enabled
```

The business meaning for this task is enable/disable login access, so `is_customer_enabled` is the clearer name.

## Required changes

### 1. Ensure admin customer LiveView namespace

The admin customer LiveView must use this module name:

```elixir
CaHeoShopWeb.Admin.CustomerLive
```

The file should be located at:

```text
lib/ca_heo_shop_web/live/admin/customer_live.ex
```

If the current customer LiveView is placed directly under:

```text
lib/ca_heo_shop_web/live
```

move it into the admin folder.

Example module declaration:

```elixir
defmodule CaHeoShopWeb.Admin.CustomerLive do
  use CaHeoShopWeb, :live_view
end
```

Update router references so `/admin/customers` uses:

```elixir
CaHeoShopWeb.Admin.CustomerLive
```

Do not change the route path.

### 2. Add customer fields to users table

Create a migration to add these fields to the `users` table:

```elixir
add :phone_number, :string
add :is_customer_enabled, :boolean, default: true, null: false
```

Expected behavior:

* Existing users should have `is_customer_enabled = true`.
* New users should default to enabled.
* `phone_number` can be nullable for now.

### 3. Update `CaHeoShop.Accounts.User`

Update the user schema to include:

```elixir
field :phone_number, :string
field :is_customer_enabled, :boolean, default: true
```

Update changesets if needed.

Do not break existing auth behavior.

### 4. Prevent disabled customers from logging in

Update login/authentication logic so that customers with:

```elixir
role == "customer"
is_customer_enabled == false
```

cannot log in.

Expected behavior:

* Disabled customers cannot create a valid login session.
* Admin and system users should not be blocked by this customer-specific flag.
* Existing error UX can be reused.
* No special disabled-account message is required in this task unless easy to add cleanly.

Do not change authorization rules unrelated to this task.

### 5. Replace mock customer data in `/admin/customers`

Replace mock customer data with real database records.

The page should list users where:

```elixir
role == "customer"
```

Recommended query function:

```elixir
CaHeoShop.Accounts.list_customers(params)
```

The query should support:

```text
enabled filter
search keyword
pagination
page size
```

### 6. Add enabled / disabled dropdown filter

Add a dropdown filter on `/admin/customers` to filter by customer enabled state.

Filter options:

```text
All
Enabled
Disabled
```

Default value:

```text
All
```

Suggested query param:

```text
enabled
```

Suggested values:

```text
all
true
false
```

Expected behavior:

* `all`: show all customers.
* `true`: show only customers where `is_customer_enabled == true`.
* `false`: show only customers where `is_customer_enabled == false`.

Changing the filter should update the customer list.

Prefer keeping the filter in URL query params.

Example URLs:

```text
/admin/customers
/admin/customers?enabled=true
/admin/customers?enabled=false
```

### 7. Add search box

Add a search box to search customers by:

```text
fullname
email
```

Suggested query param:

```text
q
```

Expected behavior:

* Empty search shows all customers matching the current filter.
* Search should be case-insensitive.
* Search should match partial text.
* Search should work together with enabled/disabled filter.
* Search should reset or normalize pagination to page 1 when the search keyword changes.

Example URLs:

```text
/admin/customers?q=linh
/admin/customers?q=gmail.com
/admin/customers?q=nguyen&enabled=true
```

Recommended query behavior:

```elixir
where:
  ilike(u.fullname, ^"%#{q}%") or
  ilike(u.email, ^"%#{q}%")
```

Handle missing or empty `fullname` safely.

### 8. Add pagination

Add pagination to the admin customer index.

Required page size options:

```text
25
50
100
```

Default page size:

```text
25
```

Suggested query params:

```text
page
page_size
```

Expected behavior:

* Default page is `1`.
* Default page size is `25`.
* Page size can only be one of `25`, `50`, or `100`.
* Invalid page size should fall back to `25`.
* Invalid page number should fall back to `1`.
* Pagination should work together with search and enabled/disabled filter.
* Changing search/filter/page size should reset or normalize to page 1.
* Pagination UI should include previous/next controls.
* Show a record count summary.

Suggested record count format:

```text
Showing 1-25 of 80 customers
```

When there are no customers:

```text
Showing 0 customers
```

### 9. Update customer table columns

The admin customer index table should include real customer information.

Required columns:

```text
Name / Full name
Email
Phone number
Enabled
Created at
Actions
```

Use available fields from the current `users` table.

If `fullname` exists, display it.

If `fullname` is missing or empty, display a fallback such as:

```text
-
```

For `phone_number`, display:

```text
-
```

when the value is missing.

For `is_customer_enabled`, display a clear visual state such as:

```text
Enabled
Disabled
```

or a DaisyUI badge.

### 10. Add mock action buttons per customer row

Each customer row should include these action buttons:

```text
View order
Toggle enabled
```

For this task, these buttons are mock UI only.

Required behavior:

* `View order` button should be displayed on each customer table row.
* `View order` can be a placeholder link or button.
* `Toggle enabled` button can be a placeholder button.
* Do not render the old `Show` button.
* Do not implement customer order history page in this task.
* Do not implement real `View order` navigation behavior in this task.
* Do not implement customer show page in this task.
* Do not implement real enable/disable toggle behavior in this task.
* Do not change customer state from these buttons yet.

Suggested labels:

```text
View order
Disable
```

when the customer is currently enabled.

```text
View order
Enable
```

when the customer is currently disabled.

Even though the toggle action is mock, the label should reflect the current value of `is_customer_enabled`.

### 11. Update Accounts query logic

Add or update an Accounts query function to support customer listing.

Recommended function shape:

```elixir
list_customers(params \\ %{})
```

It should support:

```text
q
enabled
page
page_size
```

Suggested return shape:

```elixir
%{
  entries: customers,
  page: page,
  page_size: page_size,
  total_entries: total_entries,
  total_pages: total_pages
}
```

The implementation can use custom Ecto queries.

Do not add a pagination dependency unless the project already uses one.

### 12. Update tests

Update or add tests for the admin customer index.

Test module should follow the new namespace:

```elixir
CaHeoShopWeb.Admin.CustomerLiveTest
```

Recommended test file path:

```text
test/ca_heo_shop_web/live/admin/customer_live_test.exs
```

Tests should cover:

```text
/admin/customers loads
/admin/customers uses the admin CustomerLive namespace
real customers are listed
non-customer users are not listed
phone_number is rendered
enabled state is rendered
search by fullname
search by email
enabled filter
disabled filter
pagination
page size 25
page size 50
page size 100
old Show button is not rendered
each customer row renders View order button
each customer row renders Enable or Disable mock button
View order button is mock only
toggle enabled button is mock only
disabled customer cannot log in
admin/system login is not blocked by is_customer_enabled
```

### 13. Keep route unchanged

Do not change the existing admin route:

```text
/admin/customers
```

Do not introduce new customer routes in this task.

### 14. Keep scope limited

Do not implement:

```text
customer show page
real View order page
real View order navigation
real toggle enable/disable event
customer edit page
customer delete
CSV export
bulk actions
recipient management
order history
```

This task only replaces mock data with real customer records, prepares the enable/disable field, and adds index filtering/search/pagination.

## Verification

Run:

```bash
mix format
mix compile
mix test
```

Manually verify:

```text
/admin/customers
```

Expected manual checks:

* The page loads successfully.
* `/admin/customers` uses `CaHeoShopWeb.Admin.CustomerLive`.
* Mock customer data is gone.
* Real users with `role == "customer"` are listed.
* Non-customer users are not listed.
* `phone_number` column is visible.
* `is_customer_enabled` state is visible.
* Each row has mock `View order` and `Enable/Disable` buttons.
* The old `Show` button is not displayed.
* Disabled customer accounts cannot log in.
* Admin and system users can still log in normally.
* Enabled/disabled dropdown defaults to `All`.
* Enabled filter shows only enabled customers.
* Disabled filter shows only disabled customers.
* Search works by `fullname`.
* Search works by `email`.
* Search works together with enabled/disabled filter.
* Pagination works.
* Page size options are `25`, `50`, and `100`.
* Invalid page/page_size params do not crash the page.

## Acceptance criteria

* Admin customer LiveView module is `CaHeoShopWeb.Admin.CustomerLive`.
* Admin customer LiveView file is located at `lib/ca_heo_shop_web/live/admin/customer_live.ex`.
* `/admin/customers` route uses `CaHeoShopWeb.Admin.CustomerLive`.
* A migration adds `phone_number` to `users`.
* A migration adds `is_customer_enabled` to `users`.
* `is_customer_enabled` is boolean, non-null, and defaults to `true`.
* `CaHeoShop.Accounts.User` includes `phone_number`.
* `CaHeoShop.Accounts.User` includes `is_customer_enabled`.
* Disabled customer users cannot log in.
* Admin and system login behavior remains unchanged.
* `/admin/customers` lists real customer users from the database.
* `/admin/customers` no longer uses mock customer data.
* Only users with `role == "customer"` are shown on the customer index.
* The customer table includes a phone number column.
* The customer table includes enabled/disabled state.
* Each customer row has a mock `View order` button.
* Each customer row has a mock `Enable/Disable` button.
* The customer table does not show the old `Show` button.
* The mock `View order` button does not navigate to a real customer order page yet.
* The mock toggle button does not change database state yet.
* The page has a dropdown filter for all/enabled/disabled customers.
* The default enabled filter is `All`.
* The page has a search box.
* Search matches customer `fullname`.
* Search matches customer `email`.
* Search is case-insensitive.
* Search works together with enabled/disabled filter.
* The page has pagination.
* Supported page sizes are `25`, `50`, and `100`.
* Default page size is `25`.
* Pagination works together with search and enabled/disabled filter.
* Existing `/admin/customers` route remains unchanged.
* Customer LiveView tests use the admin namespace.
* `mix format`, `mix compile`, and `mix test` pass.

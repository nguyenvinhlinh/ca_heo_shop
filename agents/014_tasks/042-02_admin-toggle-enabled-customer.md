# Task 042-02 - Enable and disable customer accounts from admin customer index

Date: 2026-06-16

## Goal

In the admin customer index page:

```text
/admin/customers
```

implement real enable/disable behavior for:

```text
is_customer_enabled
```

Each customer table row already has an `Enable` or `Disable` button from task `042-00`.

In this task, that button should update the database.

When a customer is disabled, that customer must not be able to log in.

## Dependency

This task depends on:

```text
042-00 - Implement real admin customer index
042-01 - Edit customer profile from admin customer index
```

Expected LiveView module:

```elixir
CaHeoShopWeb.Admin.CustomerLive
```

Expected file:

```text
lib/ca_heo_shop_web/live/admin/customer_live.ex
```

Expected customer index path:

```text
/admin/customers
```

Expected user field:

```elixir
field :is_customer_enabled, :boolean, default: true
```

## Required changes

### 1. Convert mock Enable / Disable button into real action

In each customer table row, the enable/disable button should become a real LiveView action.

Current expected button labels:

```text
Disable
```

when:

```elixir
customer.is_customer_enabled == true
```

and:

```text
Enable
```

when:

```elixir
customer.is_customer_enabled == false
```

Expected behavior:

* Clicking `Disable` sets `is_customer_enabled` to `false`.
* Clicking `Enable` sets `is_customer_enabled` to `true`.
* The customer table refreshes after the update.
* The button label updates after the database change.
* The enabled/disabled badge updates after the database change.

Suggested event name:

```elixir
"toggle_customer_enabled"
```

Suggested button data:

```elixir
phx-click="toggle_customer_enabled"
phx-value-id={customer.id}
```

### 2. Add Accounts function for toggling customer enabled state

Add an Accounts function that updates `is_customer_enabled`.

Recommended location:

```text
lib/ca_heo_shop/accounts.ex
```

Suggested function:

```elixir
toggle_customer_enabled(customer_id)
```

Expected behavior:

```text
load user by id
ensure user has role == "customer"
toggle is_customer_enabled
save to database
return {:ok, user} or {:error, reason}
```

Alternative function shape is also acceptable:

```elixir
set_customer_enabled(customer_id, enabled)
```

If using this shape, the LiveView should pass the target enabled value explicitly.

Important rule:

```text
Only customer users can be enabled or disabled through this admin customer flow.
```

Do not allow this function to update users with role:

```text
admin
system
```

### 3. Keep disabled customer login blocked

Task `042-00` should already block disabled customers from logging in.

Verify that this behavior still works after enabling/disabling customers from the admin customer index.

Expected behavior:

```elixir
role == "customer" and is_customer_enabled == false
```

must not be able to log in.

Expected behavior:

```elixir
role == "customer" and is_customer_enabled == true
```

can log in normally if credentials are valid.

Admin and system users should not be blocked by this customer-specific field.

### 4. Refresh customer list after toggle

After toggling `is_customer_enabled`, refresh the customer list using the current index state.

The page may already support:

```text
enabled filter
search query
pagination
page size
```

Expected behavior:

* Keep current search query.
* Keep current page size.
* Keep current page when possible.
* Keep current enabled filter.
* Refresh records from the database.

If the current filter no longer includes the updated customer, it is acceptable for the customer row to disappear after refresh.

Example:

```text
/admin/customers?enabled=true
```

If admin clicks `Disable`, the customer should disappear from the current `enabled=true` list after refresh.

Example:

```text
/admin/customers?enabled=false
```

If admin clicks `Enable`, the customer should disappear from the current `enabled=false` list after refresh.

### 5. Add flash message

Show a flash message after successful update.

Suggested success messages:

When disabling:

```text
Customer disabled successfully.
```

When enabling:

```text
Customer enabled successfully.
```

On failure, show an error flash.

Suggested error message:

```text
Could not update customer status.
```

### 6. Optional confirmation

A confirmation prompt is optional.

If implemented, use a simple confirmation message before disabling:

```text
Disable this customer?
```

and before enabling:

```text
Enable this customer?
```

Do not add a complex confirmation dialog in this task unless the existing UI already has a clean pattern for it.

### 7. Keep action buttons

Each customer row should continue to have:

```text
View order
Edit
Enable / Disable
```

Behavior status:

```text
View order = mock
Edit = real, from task 042-01
Enable / Disable = real, from this task
```

Do not bring back the old `Show` button.

### 8. Keep route unchanged

Do not add a new route.

Keep using:

```text
/admin/customers
```

The enable/disable behavior should be handled inside the existing LiveView.

### 9. Keep scope limited

Do not implement:

```text
customer show page
customer order history page
real View order navigation
customer delete
customer role management
customer password reset
bulk enable/disable
audit log
email notification
reason for disabling
ban duration
```

This task only implements real toggling of `is_customer_enabled`.

## Tests

Update or add tests for:

```text
test/ca_heo_shop_web/live/admin/customer_live_test.exs
```

Test module:

```elixir
CaHeoShopWeb.Admin.CustomerLiveTest
```

Required test coverage:

```text
/admin/customers renders Disable button for enabled customer
/admin/customers renders Enable button for disabled customer
clicking Disable sets is_customer_enabled to false in database
clicking Enable sets is_customer_enabled to true in database
button label updates after toggle
enabled/disabled badge updates after toggle
enabled filter refreshes after disabling customer
disabled filter refreshes after enabling customer
non-customer users cannot be toggled through this flow
disabled customer cannot log in
enabled customer can log in with valid credentials
admin/system login is not blocked by is_customer_enabled
View order remains mock
Edit behavior remains working
old Show button is not rendered
```

Also add context-level tests for the Accounts toggle function if the project has Accounts tests.

Recommended context tests:

```text
toggle_customer_enabled/1 disables an enabled customer
toggle_customer_enabled/1 enables a disabled customer
toggle_customer_enabled/1 rejects admin users
toggle_customer_enabled/1 rejects system users
toggle_customer_enabled/1 returns error for missing user
```

## Verification

Run:

```bash
mix format
mix compile
mix test
```

Manual verification:

```text
/admin/customers
```

Manual checks:

* Customer table loads.
* Enabled customer rows show `Disable`.
* Disabled customer rows show `Enable`.
* Clicking `Disable` updates the customer to disabled.
* Clicking `Enable` updates the customer to enabled.
* Enabled/disabled badge updates correctly.
* Button label updates correctly.
* Success flash appears after update.
* Search still works after toggling.
* Pagination still works after toggling.
* Page size selection still works after toggling.
* Enabled filter still works after toggling.
* Disabled filter still works after toggling.
* Disabled customers cannot log in.
* Re-enabled customers can log in again with valid credentials.
* `View order` remains mock.
* `Edit` still works.
* The old `Show` button is not displayed.

## Acceptance criteria

* `/admin/customers` still uses `CaHeoShopWeb.Admin.CustomerLive`.
* Each customer row has a real `Enable` or `Disable` button.
* Enabled customers show `Disable`.
* Disabled customers show `Enable`.
* Clicking `Disable` sets `is_customer_enabled` to `false` in the database.
* Clicking `Enable` sets `is_customer_enabled` to `true` in the database.
* The customer table refreshes after toggling.
* The enabled/disabled visual state updates after toggling.
* The button label updates after toggling.
* Success flash is shown after successful toggle.
* Error flash is shown if toggle fails.
* Only users with `role == "customer"` can be toggled by this flow.
* Admin and system users cannot be toggled by this flow.
* Disabled customer users cannot log in.
* Re-enabled customer users can log in with valid credentials.
* Admin and system login behavior remains unchanged.
* Current search/filter/pagination state is preserved when possible.
* `View order` remains mock.
* `Edit` remains working.
* The old `Show` button is not rendered.
* No new route is added.
* `mix format`, `mix compile`, and `mix test` pass.

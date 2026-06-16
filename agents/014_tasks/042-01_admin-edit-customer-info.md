# Task 042-01 - Edit customer profile from admin customer index

Date: 2026-06-16

## Goal

In the admin customer index page:

```text
/admin/customers
```

add an `Edit` button to each customer table row.

When admin clicks `Edit`, show a dialog containing a form that allows admin to edit:

```text
fullname
phone_number
```

The dialog form should include:

```text
Save
Cancel
```

The `Save` action must persist changes to the database.

## Dependency

This task depends on task `042-00`.

Expected existing LiveView module:

```elixir
CaHeoShopWeb.Admin.CustomerLive
```

Expected file:

```text
lib/ca_heo_shop_web/live/admin/customer_live.ex
```

Expected customer listing path:

```text
/admin/customers
```

Expected user fields from task `042-00`:

```text
fullname
phone_number
is_customer_enabled
```

## Required changes

### 1. Add Edit button to each customer table row

In the customer table action column, add an `Edit` button for each customer record.

Existing mock buttons should remain:

```text
View order
Enable / Disable
```

New action buttons per row:

```text
View order
Edit
Enable / Disable
```

`Edit` is the only real action implemented in this task.

`View order` remains mock.

`Enable / Disable` remains mock.

### 2. Open edit dialog when clicking Edit

When admin clicks `Edit`, open a dialog.

The dialog should show a form for the selected customer.

Required form fields:

```text
fullname
phone_number
```

The form should be prefilled with the selected customer's current values.

Suggested LiveView assigns:

```elixir
:editing_customer
:customer_form
```

Suggested event:

```elixir
handle_event("edit_customer", %{"id" => customer_id}, socket)
```

The event should:

```text
load the customer by id
ensure the user has role == "customer"
build a form changeset
open the dialog
```

### 3. Add edit customer changeset

Add a changeset suitable for admin editing customer profile fields.

Recommended location:

```text
lib/ca_heo_shop/accounts/user.ex
```

Suggested function:

```elixir
def admin_customer_profile_changeset(user, attrs) do
  user
  |> cast(attrs, [:fullname, :phone_number])
  |> validate_length(:fullname, max: 255)
  |> validate_length(:phone_number, max: 50)
end
```

Keep validation simple.

Do not allow this form to update:

```text
email
role
password
is_customer_enabled
confirmed_at
```

### 4. Add Accounts update function

Add an Accounts function to update customer profile data from admin.

Recommended location:

```text
lib/ca_heo_shop/accounts.ex
```

Suggested function:

```elixir
update_customer_profile(user_or_id, attrs)
```

Expected behavior:

```text
load customer if id is passed
ensure the user has role == "customer"
update only fullname and phone_number
return {:ok, user} or {:error, changeset}
```

Do not allow updating admin or system users through this function.

### 5. Save edited customer to database

Implement the save event in `CaHeoShopWeb.Admin.CustomerLive`.

Suggested event:

```elixir
handle_event("save_customer", %{"user" => customer_params}, socket)
```

Expected behavior on success:

```text
update the selected customer in the database
close the dialog
refresh the customer list using current filter/search/pagination params
show a success flash message
```

Suggested success flash:

```text
Customer updated successfully.
```

Expected behavior on validation error:

```text
keep the dialog open
show validation errors in the form
do not lose entered values
```

### 6. Cancel closes dialog without saving

Implement `Cancel` button behavior.

Suggested event:

```elixir
handle_event("cancel_edit_customer", _params, socket)
```

Expected behavior:

```text
close the dialog
clear editing_customer assign
clear customer_form assign
do not update database
```

The dialog should also be closable without saving if the existing UI pattern supports closing modals.

### 7. Preserve current index state after save/cancel

The customer index may already support:

```text
enabled filter
search query
pagination
page size
```

Editing a customer should not reset these unnecessarily.

After successful save:

```text
keep current search/filter/page_size
keep current page when possible
refresh visible list from database
```

If the updated customer no longer matches current filters, it is acceptable for the customer to disappear from the current list after refresh.

### 8. Keep route unchanged

Do not add a new route.

Keep using:

```text
/admin/customers
```

The edit dialog should be handled inside the existing LiveView.

### 9. Keep scope limited

Do not implement:

```text
customer show page
customer order history page
real View order navigation
real Enable / Disable toggle behavior
editing customer email
editing customer role
editing customer password
deleting customer
bulk edit
audit log
```

This task only implements editing `fullname` and `phone_number` from the admin customer index dialog.

## UI requirements

The dialog should have a clear title, such as:

```text
Edit customer
```

The form fields should be labeled:

```text
Full name
Phone number
```

The buttons should be:

```text
Save
Cancel
```

Suggested DaisyUI style:

```text
modal
modal-box
input input-bordered
btn
btn-primary
btn-ghost
```

Use the existing project UI conventions if they differ.

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
/admin/customers renders Edit button for each customer row
clicking Edit opens dialog
dialog is prefilled with selected customer fullname
dialog is prefilled with selected customer phone_number
Save updates fullname in database
Save updates phone_number in database
Save closes dialog after success
Cancel closes dialog without saving
validation errors keep dialog open
non-customer users cannot be edited by this admin customer edit flow
View order remains mock
Enable / Disable remains mock
```

Also test that saving does not update restricted fields:

```text
email
role
is_customer_enabled
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
* Each customer row has `View order`, `Edit`, and `Enable / Disable`.
* Clicking `Edit` opens a dialog.
* Dialog shows current `fullname`.
* Dialog shows current `phone_number`.
* Clicking `Cancel` closes the dialog without saving.
* Editing `fullname` and clicking `Save` persists the new fullname.
* Editing `phone_number` and clicking `Save` persists the new phone number.
* After saving, customer table shows updated data.
* Existing search/filter/pagination still works.
* `View order` is still mock.
* `Enable / Disable` is still mock.

## Acceptance criteria

* `/admin/customers` still uses `CaHeoShopWeb.Admin.CustomerLive`.
* Each customer table row has an `Edit` button.
* Clicking `Edit` opens a dialog.
* The dialog contains a form for `fullname` and `phone_number`.
* The form is prefilled with the selected customer's current data.
* The dialog has `Save` and `Cancel` buttons.
* `Cancel` closes the dialog without saving.
* `Save` updates `fullname` in the database.
* `Save` updates `phone_number` in the database.
* `Save` closes the dialog after successful update.
* Validation errors keep the dialog open.
* The update logic only allows editing users with `role == "customer"`.
* The edit form cannot update `email`.
* The edit form cannot update `role`.
* The edit form cannot update `password`.
* The edit form cannot update `is_customer_enabled`.
* Existing customer index search/filter/pagination remains working.
* `View order` remains mock.
* `Enable / Disable` remains mock.
* No new route is added.
* `mix format`, `mix compile`, and `mix test` pass.

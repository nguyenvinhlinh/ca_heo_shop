# Task 039-10: Admin Edit Product Content Dialog

## Filename

`039-11_admin_edit_product_content_dialog.md`

## Goal

Add edit behavior for the `Product content` section on the admin product show page.

Target page:

```text
/admin/product/:id
```

If the actual route in the project is plural:

```text
/admin/products/:id
```

use the existing route.

This task adds an `Edit` button inside the `Product content` section.

When admin clicks `Edit`, a dialog/modal should open.

The dialog contains a form that allows editing only:

```text
description_vi
description_en
```

Do not allow editing product summary fields in this task.

Do not allow editing variants or images in this task.

## Background

Previous tasks created the admin product detail/show page and added product variant/image management areas.

The product detail page likely has separate sections:

```text
Product Summary
Product content
Product variants
Product images
```

This task focuses only on:

```text
Product content
```

## Route

Use the existing admin product show route:

```text
/admin/product/:id
```

or, if the project already uses the plural route:

```text
/admin/products/:id
```

Do not create a separate full page route for editing product content.

The edit form should appear in a dialog/modal on the product show page.

## Authorization Requirement

Only users with role:

```text
admin
```

can access and use this feature.

If Task 035 already protects `/admin/*`, reuse that behavior.

Do not add new role or permission logic in this task.

## Dependencies

This task depends on:

```text
Task 035: admin route authorization exists
Task 039-01: admin product detail shell exists
```

Expected schema:

```text
CaHeoShop.Products.Product
```

Expected context:

```text
CaHeoShop.Products
```

Expected product fields:

```text
description_vi
description_en
```

## Scope

Implement edit product content behavior on the admin product show page.

Likely files:

```text
lib/ca_heo_shop/products.ex
lib/ca_heo_shop/products/product.ex
lib/ca_heo_shop_web/live/admin/product_live/show.ex
lib/ca_heo_shop_web/live/admin/product_live/show.html.heex
test/ca_heo_shop/products_test.exs
test/ca_heo_shop_web/live/admin/product_live/show_test.exs
```

If the project uses LiveComponents for forms, likely add or update:

```text
lib/ca_heo_shop_web/live/admin/product_live/product_content_form_component.ex
```

Actual file names may differ depending on the current project structure.

## Do Not Implement

Do not implement:

```text
edit collection_id
edit slug
edit name_vi
edit name_en
edit product variants
edit product images
upload product image
delete product
stock adjustment
inventory movement
SEO fields
```

This task only updates:

```text
description_vi
description_en
```

## UI Requirement

In the `Product content` section, add a button:

```text
Edit
```

Recommended placement:

```text
Product content                         [Edit]
```

When admin clicks `Edit`:

```text
open dialog/modal
show edit product content form
```

## Dialog Requirement

Dialog title:

```text
Edit Product Content
```

Dialog should contain:

```text
form fields
Update content button
Cancel button
```

Cancel should close the dialog without updating anything.

Successful update should:

```text
update product content
close dialog
refresh Product content section
show success flash
```

Recommended success flash:

```text
Product content updated successfully.
```

Invalid submit should:

```text
keep dialog open
show validation errors
do not update product
```

## Editable Fields

The form must include only these fields:

```text
description_vi
description_en
```

Do not include:

```text
collection_id
slug
name_vi
name_en
inserted_at
updated_at
product variant fields
product image fields
```

## Field Behavior

Both fields can be nullable or empty:

```text
description_vi can be nil
description_en can be nil
```

If the admin clears a description field, save it as either:

```text
nil
```

or:

```text
""
```

Follow the existing project convention.

Recommended behavior:

```text
empty string -> nil
```

if the project already normalizes empty text fields.

## Product Schema Requirements

Update or verify:

```text
lib/ca_heo_shop/products/product.ex
```

Expected fields:

```elixir
field :description_vi, :string
field :description_en, :string
```

Add a dedicated changeset for product content editing.

Recommended:

```elixir
def content_changeset(product, attrs) do
  product
  |> cast(attrs, [:description_vi, :description_en])
  |> validate_length(:description_vi, max: 10_000)
  |> validate_length(:description_en, max: 10_000)
end
```

If the project already has a different max length convention, follow it.

Do not use the full product changeset if it requires unrelated fields such as:

```text
slug
name_vi
name_en
```

Reason:

```text
This dialog edits only product content.
```

## Products Context Requirements

Update:

```text
lib/ca_heo_shop/products.ex
```

Add dedicated context helpers:

```elixir
update_product_content(%Product{} = product, attrs)
change_product_content(%Product{} = product, attrs \\ %{})
```

Expected behavior:

```text
update_product_content/2 updates description_vi and description_en only
update_product_content/2 validates content fields
update_product_content/2 returns {:ok, product} on success
update_product_content/2 returns {:error, changeset} on failure
change_product_content/2 returns a changeset
```

Recommended implementation:

```elixir
def update_product_content(%Product{} = product, attrs) do
  product
  |> Product.content_changeset(attrs)
  |> Repo.update()
end

def change_product_content(%Product{} = product, attrs \\ %{}) do
  Product.content_changeset(product, attrs)
end
```

Do not add variant or image logic to these functions.

## Field Restriction Requirement

Only these fields may be updated by this feature:

```text
description_vi
description_en
```

If submitted params contain unexpected fields, ignore them.

Examples of ignored malicious/unwanted fields:

```text
slug
name_vi
name_en
collection_id
```

Test this explicitly.

## LiveView State Requirements

The product show LiveView should track product content edit dialog state.

Recommended assigns:

```elixir
:product_content_form
:show_product_content_dialog
```

Expected events:

```text
open-edit-product-content-dialog
close-edit-product-content-dialog
validate-product-content
save-product-content
```

## Recommended Event Behavior

### Open edit dialog

Event:

```text
open-edit-product-content-dialog
```

Expected behavior:

```text
build changeset from current product
assign form
open dialog
```

### Validate product content

Event:

```text
validate-product-content
```

Expected behavior:

```text
validate form data
keep dialog open
show validation errors
```

Recommended changeset action:

```elixir
Map.put(changeset, :action, :validate)
```

### Save product content

Event:

```text
save-product-content
```

Expected behavior:

```text
update product using current product from socket
ignore unexpected fields
reload product with preloads
close dialog
show success flash
```

Important:

```text
Only allow description_vi and description_en.
```

## Refresh Behavior After Update

After successful update:

```text
reload current product detail data
refresh Product content section
close dialog
show success flash
```

The page should continue showing existing variants/images as before.

Do not require a full browser reload.

LiveView assign update is preferred.

## Dialog Implementation Options

Use the project’s existing modal/dialog pattern if available.

Acceptable options:

```text
DaisyUI modal
HTML dialog
existing Phoenix CoreComponents modal
custom LiveView modal component
```

Prefer existing project convention.

Do not introduce a large frontend dependency.

## Product Content Display After Update

After update, the `Product content` section should immediately show the new values:

```text
description_vi
description_en
```

If a description is empty, display fallback text:

```text
—
```

or the existing empty-field style from the product show page.

## Product Summary Fields Must Remain Unchanged

This task must not update:

```text
collection_id
slug
name_vi
name_en
```

Even if malicious params include these fields, they should be ignored by the content update path.

Test this explicitly.

## Tests

Add or update Products context tests.

### Context Tests

Test:

```text
update_product_content/2 updates description_vi
update_product_content/2 updates description_en
update_product_content/2 allows nil description_vi
update_product_content/2 allows nil description_en
update_product_content/2 rejects description_vi longer than max length
update_product_content/2 rejects description_en longer than max length
update_product_content/2 ignores collection_id
update_product_content/2 ignores slug
update_product_content/2 ignores name_vi
update_product_content/2 ignores name_en
change_product_content/2 returns a changeset
```

## LiveView Tests

Add tests for:

```text
/admin/product/:id
```

or the existing route:

```text
/admin/products/:id
```

### Rendering Tests

Test:

```text
Product content renders Edit button
clicking Edit opens dialog
dialog title is Edit Product Content
dialog renders description_vi field
dialog renders description_en field
dialog renders Update content button
dialog renders Cancel button
dialog does not render collection field
dialog does not render slug field
dialog does not render name_vi field
dialog does not render name_en field
dialog does not render product variant fields
dialog does not render product image fields
```

### Update Success Test

Test:

```text
admin clicks Edit in Product content
admin submits valid product content form
product content is updated
dialog closes
success flash is shown
Product content shows updated description_vi
Product content shows updated description_en
```

### Update Validation Test

Test:

```text
admin submits invalid product content form
dialog remains open
validation errors are shown
product content is not updated
```

### Empty Content Test

Test:

```text
admin clears description_vi
admin clears description_en
Product content displays empty fallback
page does not crash
```

### Field Restriction Test

Test:

```text
submitted collection_id is ignored
submitted slug is ignored
submitted name_vi is ignored
submitted name_en is ignored
product summary fields remain unchanged
```

### Existing Page Behavior Test

Verify existing sections still work:

```text
Product Summary still renders
Product variants table still renders if implemented
Product image panel still renders if implemented
```

Do not over-test all previous features, but make sure the page is not broken.

## Authorization Tests

If earlier tasks already cover product detail authorization, do not duplicate too much.

At minimum, verify:

```text
admin can use Product content Edit button
customer cannot access admin product show page
system cannot access admin product show page
anonymous user redirects to login
```

## Acceptance Criteria

The task is complete when:

```text
mix test passes
admin product show page still works
Product content has Edit button
clicking Edit opens dialog
dialog contains description_vi field
dialog contains description_en field
dialog does not contain collection field
dialog does not contain slug field
dialog does not contain name_vi field
dialog does not contain name_en field
dialog does not contain variant fields
dialog does not contain image fields
admin can update description_vi
admin can update description_en
admin can clear description_vi
admin can clear description_en
collection_id is not updated by this dialog
slug is not updated by this dialog
name_vi is not updated by this dialog
name_en is not updated by this dialog
invalid submit keeps dialog open
validation errors are shown
successful submit closes dialog
success flash appears after update
Product content refreshes after update
existing product summary area still works
existing product variants area still works if implemented
existing product images area still works if implemented
```

## Notes

Keep this task focused on editing product content only.

This task intentionally edits only:

```text
description_vi
description_en
```

Future tasks can add:

```text
edit product summary
delete product
rich text editor
Markdown preview
SEO content
product visibility controls
```

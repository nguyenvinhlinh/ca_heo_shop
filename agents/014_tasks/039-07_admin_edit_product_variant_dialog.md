# Task 039-07: Admin Edit Product Variant Dialog

## Filename

`039-07_admin_edit_product_variant_dialog.md`

## Goal

Add edit product variant behavior to the admin product detail page.

Target page:

```text
/admin/products/:id
```

On the product variants table, each product variant record already has an `edit` button from earlier tasks.

In this task, clicking `edit` should open a dialog/modal.

The dialog contains a form for updating the selected:

```text
product_variant
```

The updated product variant must belong to the current product.

## Background

Previous tasks:

```text
039-01 -> admin product detail shell
039-02 -> readonly product variants table with static edit/remove buttons
039-06 -> create product variant dialog
```

Task `039-06` added the ability to create product variants from the product detail page.

This task adds the ability to edit existing product variants.

## Route

Use the existing admin product detail route:

```text
/admin/products/:id
```

Do not create a separate full page route for editing product variants.

The edit form should appear in a dialog/modal on the product detail page.

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
Task 032: product_variants table exists
Task 035: admin route authorization exists
Task 039-01: admin product detail shell exists
Task 039-02: product variants readonly table exists
Task 039-06: create product variant dialog exists
```

Expected schemas:

```text
CaHeoShop.Products.Product
CaHeoShop.Products.ProductVariant
```

Expected context:

```text
CaHeoShop.Products
```

Expected relationship:

```text
products has many product_variants
product_variants belongs to product
```

## Scope

Implement edit product variant behavior on the admin product detail page.

Likely files:

```text
lib/ca_heo_shop/products.ex
lib/ca_heo_shop/products/product_variant.ex
lib/ca_heo_shop_web/live/admin/product_live/show.ex
lib/ca_heo_shop_web/live/admin/product_live/show.html.heex
test/ca_heo_shop/products_test.exs
test/ca_heo_shop_web/live/admin/product_live/show_test.exs
```

If Task `039-06` introduced a form component, likely update:

```text
lib/ca_heo_shop_web/live/admin/product_live/variant_form_component.ex
```

Actual file names may differ depending on the current project structure.

## Do Not Implement

Do not implement:

```text
remove product variant
delete product variant
variant image upload
product image upload
stock adjustment history
inventory movements
variant reorder drag-drop
variant image picker
```

The `remove` button should remain static.

This task only edits existing product variant fields.

## UI Requirement

In the product variants table, each row should have an `edit` button.

Before this task, the button may have been static.

After this task, the `edit` button should open a dialog for that row.

Recommended button label:

```text
Edit
```

Recommended event:

```text
open-edit-variant-dialog
```

Example markup:

```heex
<button
  type="button"
  class="btn btn-xs"
  phx-click="open-edit-variant-dialog"
  phx-value-id={product_variant.id}
>
  Edit
</button>
```

Do not make the `remove` button functional in this task.

## Dialog Requirement

The dialog title should be:

```text
Edit product variant
```

The dialog should contain:

```text
form fields
Update variant button
Cancel button
```

Cancel should close the dialog without updating anything.

Successful update should:

```text
update product variant
close dialog
refresh variants table
show success flash
```

Recommended success flash:

```text
Product variant updated successfully.
```

Invalid submit should:

```text
keep dialog open
show validation errors
do not update product variant
```

## Product Variant Fields

The edit form should contain fields from the current `product_variants` schema.

Base fields:

```text
variant_name
production_cost
selling_price
stock_quantity
image_filename
display_order
```

Hidden or implicit fields:

```text
id
product_id
```

Important:

```text
product_id must not be editable
product_id must not be changed by submitted params
```

The variant must remain attached to the current product.

## Optional Bilingual Field Handling

If the project has bilingual variant name fields, include them in the edit form:

```text
variant_name_vi
variant_name_en
```

If these fields exist in the current `ProductVariant` schema, edit form fields should be:

```text
variant_name
variant_name_vi
variant_name_en
production_cost
selling_price
stock_quantity
image_filename
display_order
```

If bilingual fields do not exist, use only:

```text
variant_name
production_cost
selling_price
stock_quantity
image_filename
display_order
```

Do not add a migration in this task.

This task should follow the current actual `ProductVariant` schema.

## Field Behavior

Expected behavior:

```text
variant_name is required
production_cost is required
selling_price is required
stock_quantity is required
display_order is required
image_filename is optional
```

Numeric fields:

```text
production_cost >= 0
selling_price >= 0
stock_quantity >= 0
display_order >= 0
```

Money fields should use integer VND amounts:

```text
production_cost
selling_price
```

Do not use float.

Do not introduce a money library.

## Image Filename Requirement

The form may include:

```text
image_filename
```

as a plain text input.

Do not implement file upload.

Do not implement product image picker.

Do not validate that the file exists on disk in this task.

If `image_filename` is empty, save it as:

```text
nil
```

or let the changeset handle it according to the existing project style.

## Products Context Requirements

Ensure the Products context has:

```elixir
update_product_variant(%ProductVariant{} = product_variant, attrs)
change_product_variant(%ProductVariant{} = product_variant, attrs \\ %{})
```

If these functions already exist from Task 032, reuse them.

Expected behavior:

```text
update_product_variant/2 updates product variant
update_product_variant/2 validates fields
update_product_variant/2 returns {:ok, product_variant} on success
update_product_variant/2 returns {:error, changeset} on failure
```

Do not create a new context.

Keep using:

```text
CaHeoShop.Products
```

Do not create:

```text
CaHeoShop.ProductVariants
```

## Variant Ownership Safety Requirement

Only allow editing product variants that belong to the current product.

When opening edit dialog:

```text
find variant from current product's loaded product_variants
```

Do not blindly load any variant by id.

Recommended helper behavior:

```elixir
defp find_product_variant(product, variant_id) do
  Enum.find(product.product_variants, fn product_variant ->
    to_string(product_variant.id) == to_string(variant_id)
  end)
end
```

If variant id does not belong to the current product:

```text
do not open dialog
show error flash or ignore safely
do not crash
```

Recommended error flash:

```text
Product variant not found.
```

When saving update:

```text
use the selected_product_variant from socket assigns
ignore any submitted product_id
keep product_id unchanged
```

Do not allow malicious params to move a variant to another product.

## LiveView State Requirements

The product detail LiveView should track edit dialog state.

Recommended assigns:

```elixir
:variant_form
:show_variant_dialog
:variant_dialog_action
:selected_product_variant
```

Suggested values:

```text
variant_dialog_action = :new
variant_dialog_action = :edit
```

If Task `039-06` already has dialog state, reuse and extend it rather than creating duplicate modal logic.

Expected events:

```text
open-edit-variant-dialog
close-variant-dialog
validate-variant
save-variant
```

If Task `039-06` already uses:

```text
open-new-variant-dialog
close-new-variant-dialog
validate-variant
save-variant
```

then update the implementation so `save-variant` can handle both create and edit based on action.

## Recommended Event Behavior

### Open edit dialog

```text
open-edit-variant-dialog
```

Expected behavior:

```text
find selected variant in current product
build changeset with current variant data
assign form
set variant_dialog_action = :edit
open dialog
```

### Validate variant

```text
validate-variant
```

Expected behavior:

```text
validate current form data
keep dialog open
show validation errors
```

For edit action, validate using:

```elixir
Products.change_product_variant(selected_product_variant, params)
```

### Save variant

```text
save-variant
```

For edit action:

```elixir
Products.update_product_variant(selected_product_variant, sanitized_params)
```

Important:

```text
force product_id to remain unchanged
or remove product_id from submitted params
```

After success:

```text
reload current product with variants
close dialog
clear selected_product_variant
show success flash
```

After error:

```text
keep dialog open
show validation errors
```

## Reuse Create Variant Dialog If Possible

If Task `039-06` already created a variant form component, reuse it.

The same form component can support:

```text
:new
:edit
```

Recommended component assigns:

```text
action
form
title
submit_label
```

Example values:

```text
new title: New product variant
new submit label: Create variant

edit title: Edit product variant
edit submit label: Update variant
```

Do not duplicate the full form markup if a reusable component exists.

## Refresh Behavior After Update

After successful update:

```text
reload current product with variants
close dialog
update variants table
show success flash
```

Variants should still be ordered by:

```text
display_order ascending
inserted_at ascending
```

Do not require full page reload.

LiveView assign update is preferred.

## Static Remove Button

The existing `remove` button in the variants table should remain static.

Do not wire it to any behavior.

Preferred remove button:

```heex
<button type="button" class="btn btn-xs btn-error" disabled>
  Remove
</button>
```

or keep the existing static style.

Do not add:

```text
phx-click
data-confirm
href
JS command
```

to remove button.

## Empty State Behavior

If the product has no variants:

```text
show No variants
show New variant button if Task 039-06 added it
do not show edit buttons
```

The page should not crash.

## Tests

Add or update Products context tests.

### Context Tests

Test:

```text
update_product_variant/2 updates variant_name
update_product_variant/2 updates production_cost
update_product_variant/2 updates selling_price
update_product_variant/2 updates stock_quantity
update_product_variant/2 updates image_filename
update_product_variant/2 updates display_order
update_product_variant/2 rejects invalid attrs
update_product_variant/2 rejects negative production_cost
update_product_variant/2 rejects negative selling_price
update_product_variant/2 rejects negative stock_quantity
update_product_variant/2 rejects negative display_order
```

If bilingual fields exist, test:

```text
update_product_variant/2 updates variant_name_vi
update_product_variant/2 updates variant_name_en
```

## LiveView Tests

Add tests for:

```text
/admin/products/:id
```

### Rendering Tests

Test:

```text
variant row renders Edit button
clicking Edit opens dialog
dialog title is Edit product variant
dialog renders existing variant values
dialog renders variant_name field
dialog renders production_cost field
dialog renders selling_price field
dialog renders stock_quantity field
dialog renders image_filename field
dialog renders display_order field
dialog renders Update variant button
dialog renders Cancel button
```

If bilingual fields exist, also test:

```text
dialog renders variant_name_vi field
dialog renders variant_name_en field
dialog renders existing variant_name_vi value
dialog renders existing variant_name_en value
```

### Update Success Test

Test:

```text
admin clicks Edit for a variant
admin submits valid update form
product variant is updated
dialog closes
success flash is shown
variants table shows updated values
```

### Update Validation Test

Test:

```text
admin submits invalid update form
dialog remains open
validation errors are shown
product variant is not updated
```

### Product Ownership Test

Test:

```text
editing variant from current product works
attempting to open edit dialog for variant from another product is ignored or shows error
submitted product_id from client is ignored
variant remains attached to original product
```

### Remove Button Test

Verify remove button remains static:

```text
remove button is rendered
remove button has no behavior
remove button does not have phx-click
```

### Empty State Test

Test:

```text
product without variants shows No variants
product without variants does not render edit buttons
```

## Authorization Tests

If earlier tasks already cover product detail authorization, do not duplicate too much.

At minimum, verify:

```text
admin can use Edit variant button
customer cannot access /admin/products/:id
system cannot access /admin/products/:id
anonymous user redirects to login
```

## Acceptance Criteria

The task is complete when:

```text
mix test passes
/admin/products/:id still works
variant rows have functional Edit button
clicking Edit opens dialog
dialog is prefilled with selected variant values
dialog contains product variant update form
form includes variant_name
form includes production_cost
form includes selling_price
form includes stock_quantity
form includes image_filename
form includes display_order
product_id is not editable
submitted product_id cannot move variant to another product
admin can update product variant
updated variant appears in variants table
dialog closes after successful update
success flash appears after successful update
invalid submit keeps dialog open
validation errors are shown
variant is not updated on invalid submit
editing variant from another product is rejected or ignored safely
remove button remains static
no remove variant behavior is implemented
no image upload behavior is implemented
no stock adjustment history is implemented
```

## Notes

Keep this task focused on editing product variants.

This task does not remove variants.

Future tasks can add:

```text
remove product variant behavior
variant image picker
variant reorder
stock adjustment
inventory movement tracking
```

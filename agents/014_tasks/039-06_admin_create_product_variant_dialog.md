# Task 039-06: Admin Create Product Variant Dialog

## Filename

`039-06_admin_create_product_variant_dialog.md`

## Goal

Add a create product variant feature to the admin product detail page.

Target page:

```text
/admin/products/:id
```

On the product detail page, admin should see a button:

```text
New variant
```

When clicking this button, a dialog/modal should open.

The dialog contains a form for creating a new row in:

```text
product_variants
```

The new product variant must belong to the current product.

## Background

Previous tasks:

```text
039-01 -> admin product detail shell
039-02 -> readonly product variants table
039-03 -> product image preview and thumbnail list
039-04 -> image preview selection
039-05 -> product image drag-drop ordering
```

Task `039-02` added a readonly product variants table.

This task adds the ability to create a product variant from that page.

## Route

Use the existing admin product detail route:

```text
/admin/products/:id
```

Do not create a separate full page route for creating product variants.

The create form should appear in a dialog/modal on the product detail page.

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

Implement create product variant behavior on the admin product detail page.

Likely files:

```text
lib/ca_heo_shop/products.ex
lib/ca_heo_shop/products/product_variant.ex
lib/ca_heo_shop_web/live/admin/product_live/show.ex
lib/ca_heo_shop_web/live/admin/product_live/show.html.heex
test/ca_heo_shop/products_test.exs
test/ca_heo_shop_web/live/admin/product_live/show_test.exs
```

If the project uses LiveComponents for forms, likely add:

```text
lib/ca_heo_shop_web/live/admin/product_live/variant_form_component.ex
```

Actual file names may differ depending on the current project structure.

## Do Not Implement

Do not implement:

```text
edit product variant
remove product variant
delete product variant
variant image upload
product image upload
stock adjustment history
inventory movements
variant reorder drag-drop
variant image picker
```

The existing `edit` and `remove` buttons from Task `039-02` should remain static placeholders.

This task only creates a new product variant.

## UI Requirement

Add a button near the product variants section:

```text
New variant
```

Recommended placement:

```text
Product variants section header, right side
```

Example layout:

```text
Product variants                         [New variant]
```

When admin clicks `New variant`:

```text
open dialog/modal
show create product variant form
```

## Dialog Requirement

The dialog title should be:

```text
New product variant
```

The dialog should contain:

```text
form fields
Create variant button
Cancel button
```

Cancel should close the dialog without creating anything.

Successful create should:

```text
create product variant
close dialog
refresh variants table
show success flash
```

Recommended success flash:

```text
Product variant created successfully.
```

Invalid submit should:

```text
keep dialog open
show validation errors
do not create product variant
```

## Product Variant Fields

The form should contain fields from the `product_variants` table.

Required form fields:

```text
variant_name
production_cost
selling_price
stock_quantity
image_filename
display_order
```

Hidden or implicit field:

```text
product_id
```

`product_id` must come from the current product detail page.

Do not let the admin choose another product inside the dialog.

The created variant must belong to:

```text
/admin/products/:id
```

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

Do not introduce money library.

## Optional Bilingual Field Handling

If the project has already added bilingual variant name fields, include them in the form too:

```text
variant_name_vi
variant_name_en
```

If these fields exist in the current `ProductVariant` schema, form fields should be:

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

If bilingual fields do not exist yet, use only:

```text
variant_name
production_cost
selling_price
stock_quantity
image_filename
display_order
```

Do not add a new migration in this task just for bilingual names.

This task should follow the current actual `ProductVariant` schema.

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

## Display Order Default

When opening the form, default `display_order` should be the next available order for the current product.

Recommended behavior:

```text
if product has no variants -> display_order = 0
if product has variants -> max(display_order) + 1
```

Example:

```text
existing variants display_order: 0, 1, 2
new variant default display_order: 3
```

If the admin changes display_order manually, respect the submitted value.

Do not implement automatic reorder of existing variants in this task.

## Products Context Requirements

Ensure the Products context has:

```elixir
create_product_variant(attrs \\ %{})
change_product_variant(%ProductVariant{} = product_variant, attrs \\ %{})
```

If these functions already exist from Task 032, reuse them.

Expected behavior:

```text
create_product_variant/1 inserts product variant
create_product_variant/1 validates fields
create_product_variant/1 returns {:ok, product_variant} on success
create_product_variant/1 returns {:error, changeset} on failure
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

## Optional Context Helper

Add a helper for default display order if useful:

```elixir
next_product_variant_display_order(product_id)
```

Expected behavior:

```text
returns 0 when product has no variants
returns max(display_order) + 1 when product has variants
```

Example implementation direction:

```elixir
def next_product_variant_display_order(product_id) do
  max_order =
    ProductVariant
    |> where([pv], pv.product_id == ^product_id)
    |> select([pv], max(pv.display_order))
    |> Repo.one()

  case max_order do
    nil -> 0
    value -> value + 1
  end
end
```

This helper is optional but recommended to keep LiveView clean.

## LiveView State Requirements

The product detail LiveView should track dialog state.

Recommended assigns:

```elixir
:variant_form
:show_variant_dialog
```

or use the existing modal pattern in the project.

Expected events:

```text
open-new-variant-dialog
close-new-variant-dialog
validate-variant
save-variant
```

Recommended event behavior:

```text
open-new-variant-dialog -> opens dialog with fresh changeset
close-new-variant-dialog -> closes dialog
validate-variant -> validates form and shows errors
save-variant -> creates product variant
```

## Create Variant Behavior

On save, build attrs with the current product id.

Expected behavior:

```elixir
attrs =
  params
  |> Map.put("product_id", socket.assigns.product.id)
```

Do not trust client-submitted `product_id`.

If the form includes a hidden `product_id`, it is only for display/form structure.

Server-side code must force product_id from the current product.

## Refresh Behavior After Create

After successful create:

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

## Form Validation Behavior

Support live validation if the project already uses it.

Recommended event:

```elixir
handle_event("validate-variant", %{"product_variant" => params}, socket)
```

Changeset action:

```elixir
Map.put(changeset, :action, :validate)
```

If the project does not use live validation, validating on submit only is acceptable.

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

Do not introduce a large frontend dependency for this task.

## Static Edit/Remove Buttons

The existing `edit` and `remove` buttons in the variants table should remain static.

Do not wire them to any behavior.

Only `New variant` should be functional.

## Empty State Behavior

If the product has no variants:

```text
show No variants
show New variant button
```

After creating the first variant:

```text
No variants disappears
new variant appears in the table
```

## Tests

Add or update Products context tests.

### Context Tests

Test:

```text
create_product_variant/1 creates a variant with valid attrs
create_product_variant/1 requires product_id
create_product_variant/1 requires variant_name
create_product_variant/1 requires production_cost
create_product_variant/1 requires selling_price
create_product_variant/1 requires stock_quantity
create_product_variant/1 requires display_order
create_product_variant/1 allows nil image_filename
create_product_variant/1 rejects negative production_cost
create_product_variant/1 rejects negative selling_price
create_product_variant/1 rejects negative stock_quantity
create_product_variant/1 rejects negative display_order
```

If `next_product_variant_display_order/1` is implemented, test:

```text
next_product_variant_display_order/1 returns 0 when product has no variants
next_product_variant_display_order/1 returns max display_order + 1 when product has variants
```

## LiveView Tests

Add tests for:

```text
/admin/products/:id
```

### Rendering Tests

Test:

```text
renders New variant button
does not show dialog by default
clicking New variant opens dialog
dialog renders variant_name field
dialog renders production_cost field
dialog renders selling_price field
dialog renders stock_quantity field
dialog renders image_filename field
dialog renders display_order field
dialog renders Create variant button
dialog renders Cancel button
```

If bilingual fields exist, also test:

```text
dialog renders variant_name_vi field
dialog renders variant_name_en field
```

### Create Success Test

Test:

```text
admin opens New variant dialog
admin submits valid variant form
product variant is created
dialog closes
success flash is shown
new variant appears in variants table
```

### Create Validation Test

Test:

```text
admin submits invalid variant form
dialog remains open
validation errors are shown
product variant is not created
```

### Product Ownership Test

Test:

```text
created variant belongs to current product
submitted product_id from client is ignored or overridden
```

### Empty State Test

Test:

```text
product without variants shows No variants
after creating variant, variants table shows the new variant
```

### Static Buttons Test

Verify existing buttons remain static:

```text
edit button still has no behavior
remove button still has no behavior
```

## Authorization Tests

If Task 039-01 already covers product detail authorization, do not duplicate too much.

At minimum, verify:

```text
admin can use New variant button
customer cannot access /admin/products/:id
system cannot access /admin/products/:id
anonymous user redirects to login
```

## Acceptance Criteria

The task is complete when:

```text
mix test passes
/admin/products/:id still works
admin product detail page has New variant button
clicking New variant opens dialog
dialog contains product variant form
form includes variant_name
form includes production_cost
form includes selling_price
form includes stock_quantity
form includes image_filename
form includes display_order
product_id is assigned from current product
admin can create product variant
created variant appears in variants table
dialog closes after successful create
success flash appears after successful create
invalid submit keeps dialog open
validation errors are shown
variant is not created on invalid submit
default display_order is next available order
product with no variants can create first variant
existing edit button remains static
existing remove button remains static
no edit variant behavior is implemented
no remove variant behavior is implemented
no image upload behavior is implemented
no stock adjustment history is implemented
```

## Notes

Keep this task focused on creating product variants from the product detail page.

This task does not make variants editable or removable.

Future tasks can add:

```text
edit product variant dialog
remove product variant behavior
variant image picker
variant reorder
stock adjustment
inventory movement tracking
```

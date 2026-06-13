# Task 039-10: Admin Edit Product Summary Dialog

## Filename

`039-10_admin_edit_product_summary_dialog.md`

## Goal

Add an edit product summary feature to the admin product show page.

Target page:

```text
/admin/products/:id
```

If the current project accidentally uses singular path:

```text
/admin/product/:id
```

follow the existing route in the project, but the intended admin product show page is:

```text
/admin/products/:id
```

In the `Product Summary` section, add a button:

```text
Edit Product
```

When admin clicks this button, a dialog/modal should appear.

The dialog contains a form that allows updating only these product fields:

```text
collection_id
slug
name_vi
name_en
```

Do not allow editing descriptions in this task.

Do not allow editing variants or images in this task.

## Background

Previous tasks:

```text
039-01 -> admin product detail shell
039-02 -> product variants readonly table
039-03 -> product image preview and thumbnail list
039-04 -> product image preview selection
039-05 -> product image drag-drop ordering
039-06 -> create product variant dialog
039-07 -> edit product variant dialog
039-08 -> delete product variant
039-09 -> product variant drag-drop ordering
```

This task adds editing for the base product summary fields only.

## Route

Use the existing admin product detail route:

```text
/admin/products/:id
```

Do not create a separate full page route for editing the product.

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

Expected collection schema/context:

```text
CaHeoShop.Collections.Collection
CaHeoShop.Collections
```

## Scope

Implement edit product summary behavior on the admin product detail page.

Likely files:

```text
lib/ca_heo_shop/products.ex
lib/ca_heo_shop/products/product.ex
lib/ca_heo_shop/collections.ex
lib/ca_heo_shop_web/live/admin/product_live/show.ex
lib/ca_heo_shop_web/live/admin/product_live/show.html.heex
test/ca_heo_shop/products_test.exs
test/ca_heo_shop_web/live/admin/product_live/show_test.exs
```

If the project uses LiveComponents for forms, likely add or update:

```text
lib/ca_heo_shop_web/live/admin/product_live/product_summary_form_component.ex
```

Actual file names may differ depending on the current project structure.

## Do Not Implement

Do not implement:

```text
edit description_vi
edit description_en
edit product variants
edit product images
upload product image
delete product
delete product variant
stock adjustment
inventory movement
automatic slug generation
```

This task only updates:

```text
collection_id
slug
name_vi
name_en
```

## UI Requirement

In the `Product Summary` section, add a button:

```text
Edit Product
```

Recommended placement:

```text
Product Summary                         [Edit Product]
```

When admin clicks `Edit Product`:

```text
open dialog/modal
show edit product summary form
```

## Dialog Requirement

Dialog title:

```text
Edit Product
```

Dialog should contain:

```text
form fields
Update product button
Cancel button
```

Cancel should close the dialog without updating anything.

Successful update should:

```text
update product
close dialog
refresh product summary
show success flash
```

Recommended success flash:

```text
Product updated successfully.
```

Invalid submit should:

```text
keep dialog open
show validation errors
do not update product
```

## Editable Fields

The form must include only these editable fields:

```text
collection_id
slug
name_vi
name_en
```

Do not include:

```text
description_vi
description_en
inserted_at
updated_at
product variant fields
product image fields
```

## Collection Field Requirement

The form should allow selecting a collection.

Options should include:

```text
No collection
existing collections
```

`No collection` should save:

```text
collection_id = nil
```

Collection option labels should prefer:

```text
name_vi
```

Fallback:

```text
name_en
```

If both are missing, fallback to:

```text
Collection #ID
```

Collection options should be ordered by:

```text
nav_display_order ascending
name_vi ascending
name_en ascending
```

If `nav_display_order` does not exist, order by name fields only.

## Slug Requirement

The product form should include a `slug` input.

Slug rules:

```text
required
unique
lowercase
URL-friendly
```

Recommended validation:

```text
only lowercase letters, numbers, and hyphens
```

Recommended regex:

```elixir
~r/^[a-z0-9]+(?:-[a-z0-9]+)*$/
```

Invalid examples:

```text
Universal Phone Stand
universal_phone_stand
universal phone stand
universal--phone-stand
```

Valid examples:

```text
universal-phone-stand
pla-red-phone-holder
ssd-frame
```

Do not implement automatic slug generation in this task.

The admin edits the slug manually.

## Products Context Requirements

Ensure the Products context has:

```elixir
update_product(%Product{} = product, attrs)
change_product(%Product{} = product, attrs \\ %{})
```

If these functions already exist, reuse them.

Expected behavior:

```text
update_product/2 updates product
update_product/2 validates fields
update_product/2 returns {:ok, product} on success
update_product/2 returns {:error, changeset} on failure
```

Do not add variant or image logic to `update_product/2`.

## Product Schema Requirements

Update or verify:

```text
lib/ca_heo_shop/products/product.ex
```

Expected fields:

```elixir
field :slug, :string
field :name_vi, :string
field :name_en, :string
field :description_vi, :string
field :description_en, :string

belongs_to :collection, CaHeoShop.Collections.Collection
```

Expected changeset cast fields may include all product fields:

```elixir
[
  :collection_id,
  :slug,
  :name_vi,
  :name_en,
  :description_vi,
  :description_en
]
```

However, this edit dialog must submit only:

```elixir
[
  :collection_id,
  :slug,
  :name_vi,
  :name_en
]
```

If needed, add a dedicated changeset for summary editing:

```elixir
def summary_changeset(product, attrs) do
  product
  |> cast(attrs, [:collection_id, :slug, :name_vi, :name_en])
  |> validate_required([:slug, :name_vi, :name_en])
  |> validate_format(:slug, ~r/^[a-z0-9]+(?:-[a-z0-9]+)*$/)
  |> validate_length(:slug, max: 160)
  |> validate_length(:name_vi, max: 255)
  |> validate_length(:name_en, max: 255)
  |> unique_constraint(:slug)
  |> foreign_key_constraint(:collection_id)
end
```

Then add context helpers:

```elixir
update_product_summary(%Product{} = product, attrs)
change_product_summary(%Product{} = product, attrs \\ %{})
```

Preferred direction:

```text
Use dedicated summary changeset/context helpers.
```

Reason:

```text
This task intentionally allows editing only collection, slug, name_vi, and name_en.
```

## LiveView State Requirements

The product detail LiveView should track product edit dialog state.

Recommended assigns:

```elixir
:product_summary_form
:show_product_summary_dialog
```

Expected events:

```text
open-edit-product-dialog
close-edit-product-dialog
validate-product-summary
save-product-summary
```

## Recommended Event Behavior

### Open edit dialog

Event:

```text
open-edit-product-dialog
```

Expected behavior:

```text
build changeset from current product
assign form
open dialog
```

### Validate product summary

Event:

```text
validate-product-summary
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

### Save product summary

Event:

```text
save-product-summary
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
Only allow collection_id, slug, name_vi, and name_en.
```

If submitted params contain other fields, ignore them.

## Refresh Behavior After Update

After successful update:

```text
reload current product detail data
refresh Product Summary
refresh collection display
close dialog
show success flash
```

The page should continue showing existing variants/images as before.

Do not require full browser reload.

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

## Product Summary Display After Update

After update, the `Product Summary` section should immediately show the new values:

```text
collection
slug
name_vi
name_en
```

If collection is changed to nil, display:

```text
No collection
```

## Description Fields Must Remain Unchanged

This task must not update:

```text
description_vi
description_en
```

Even if malicious params include these fields, they should be ignored by the summary update path.

Test this explicitly.

## Tests

Add or update Products context tests.

### Context Tests

If using `update_product_summary/2`, test:

```text
update_product_summary/2 updates collection_id
update_product_summary/2 updates slug
update_product_summary/2 updates name_vi
update_product_summary/2 updates name_en
update_product_summary/2 allows nil collection_id
update_product_summary/2 rejects duplicate slug
update_product_summary/2 rejects invalid slug
update_product_summary/2 requires slug
update_product_summary/2 requires name_vi
update_product_summary/2 requires name_en
update_product_summary/2 ignores description_vi
update_product_summary/2 ignores description_en
```

If using existing `update_product/2`, still add tests that this page’s submit path only permits summary fields.

## LiveView Tests

Add tests for:

```text
/admin/products/:id
```

### Rendering Tests

Test:

```text
Product Summary renders Edit Product button
clicking Edit Product opens dialog
dialog title is Edit Product
dialog renders collection field
dialog renders slug field
dialog renders name_vi field
dialog renders name_en field
dialog renders Update product button
dialog renders Cancel button
dialog does not render description_vi field
dialog does not render description_en field
dialog does not render product variant fields
dialog does not render product image fields
```

### Update Success Test

Test:

```text
admin clicks Edit Product
admin submits valid product summary form
product is updated
dialog closes
success flash is shown
Product Summary shows updated collection
Product Summary shows updated slug
Product Summary shows updated name_vi
Product Summary shows updated name_en
```

### Update Validation Test

Test:

```text
admin submits invalid product summary form
dialog remains open
validation errors are shown
product is not updated
```

### Collection Tests

Test:

```text
admin can set collection to an existing collection
admin can set collection to No collection
Product Summary shows No collection after setting collection_id to nil
```

### Field Restriction Test

Test:

```text
submitted description_vi is ignored
submitted description_en is ignored
product descriptions remain unchanged
```

### Existing Page Behavior Test

Verify existing sections still work:

```text
product variants table still renders
product image panel still renders if implemented
New variant button still works if implemented
Edit variant button still works if implemented
Remove variant button still works if implemented
variant drag-drop still works if implemented
```

Do not over-test all previous features, but make sure the page is not broken.

## Authorization Tests

If earlier tasks already cover product detail authorization, do not duplicate too much.

At minimum, verify:

```text
admin can use Edit Product button
customer cannot access /admin/products/:id
system cannot access /admin/products/:id
anonymous user redirects to login
```

## Acceptance Criteria

The task is complete when:

```text
mix test passes
/admin/products/:id still works
Product Summary has Edit Product button
clicking Edit Product opens dialog
dialog contains collection field
dialog contains slug field
dialog contains name_vi field
dialog contains name_en field
dialog does not contain description_vi field
dialog does not contain description_en field
dialog does not contain variant fields
dialog does not contain image fields
admin can update product collection
admin can set product collection to No collection
admin can update product slug
admin can update product name_vi
admin can update product name_en
description_vi is not updated by this dialog
description_en is not updated by this dialog
invalid submit keeps dialog open
validation errors are shown
success submit closes dialog
success flash appears after update
Product Summary refreshes after update
existing product variants area still works
existing product images area still works if implemented
```

## Notes

Keep this task focused on editing the product summary only.

This task intentionally edits only:

```text
collection
slug
name_vi
name_en
```

Future tasks can add:

```text
edit product descriptions
delete product
product publication status
SEO fields
automatic slug generation
product visibility controls
```

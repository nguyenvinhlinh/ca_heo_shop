# Task 039-08: Admin Delete Product Variant

## Filename

`039-08_admin_delete_product_variant.md`

## Goal

Add delete behavior for product variants on the admin product detail page.

Target page:

```text
/admin/products/:id
```

In the product variants table, each product variant row already has a `remove` button.

In this task, clicking `remove` should delete the selected:

```text
product_variant
```

This task uses hard delete.

Do not add:

```text
is_deleted
deleted_at
soft delete behavior
```

## Background

Previous tasks:

```text
039-01 -> admin product detail shell
039-02 -> readonly product variants table with static edit/remove buttons
039-06 -> create product variant dialog
039-07 -> edit product variant dialog
```

This task makes the existing `remove` button functional.

Important business decision:

```text
product_variants can be hard deleted
```

Reason:

```text
historical sale order display should rely on sale_order_items snapshot fields
```

Sale order items should preserve historical values such as:

```text
product_name_snapshot
product_slug_snapshot
variant_name_snapshot
unit_price_snapshot
production_cost_snapshot
quantity
line_total_amount
image_filename_snapshot
```

Therefore, deleting a product variant should not damage historical order display.

## Route

Use the existing admin product detail route:

```text
/admin/products/:id
```

Do not create a separate full page route for deleting product variants.

## Authorization Requirement

Only users with role:

```text
admin
```

can delete product variants.

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
Task 039-07: edit product variant dialog exists
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

Implement product variant delete behavior on the admin product detail page.

Likely files:

```text
lib/ca_heo_shop/products.ex
lib/ca_heo_shop_web/live/admin/product_live/show.ex
lib/ca_heo_shop_web/live/admin/product_live/show.html.heex
test/ca_heo_shop/products_test.exs
test/ca_heo_shop_web/live/admin/product_live/show_test.exs
```

Actual file names may differ depending on the current project structure.

## Do Not Implement

Do not implement:

```text
soft delete
is_deleted boolean
deleted_at timestamp
restore variant
bulk delete variants
sale order item deletion
inventory movement cleanup
variant archive behavior
```

This task only deletes a single product variant from the admin product detail page.

## Database Decision

Use hard delete for `product_variants`.

Do not add these fields:

```text
is_deleted
deleted_at
deleted_by_id
```

Do not hide deleted records through query filters.

Deleted product variants should be removed from the database.

## Sale Order Snapshot Safety

Historical order display must not depend on live `product_variants` data.

If `sale_order_items` already exists and references `product_variants`, make sure deleting a product variant does not delete sale order items.

Recommended future-safe relationship:

```text
sale_order_items.product_variant_id can be nullable
sale_order_items keeps snapshot fields for historical display
```

If `sale_order_items` table already exists and the foreign key blocks product variant deletion, update the foreign key behavior so product variant deletion is allowed while sale order item snapshots remain.

Preferred behavior:

```text
on delete product_variant -> sale_order_items.product_variant_id becomes nil
sale_order_items row remains
snapshot fields remain unchanged
```

Do not cascade delete sale order items.

If `sale_order_items` is not implemented yet, no sale order migration is needed in this task.

When `sale_order_items` is implemented later, remember:

```text
product_variant_id should not prevent hard deleting old variants
sale_order_items snapshots are the historical source of truth
```

## Products Context Requirements

Ensure the Products context has:

```elixir
delete_product_variant(%ProductVariant{} = product_variant)
```

If this function already exists from Task 032, reuse it.

Expected behavior:

```text
delete_product_variant/1 deletes product variant
delete_product_variant/1 returns {:ok, product_variant} on success
delete_product_variant/1 returns {:error, changeset} on failure
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

Only allow deleting product variants that belong to the current product.

When handling delete:

```text
find variant from current product's loaded product_variants
```

Do not blindly delete any variant by id.

Recommended helper:

```elixir
defp find_product_variant(product, variant_id) do
  Enum.find(product.product_variants, fn product_variant ->
    to_string(product_variant.id) == to_string(variant_id)
  end)
end
```

If variant id does not belong to the current product:

```text
do not delete anything
show error flash or ignore safely
do not crash
```

Recommended error flash:

```text
Product variant not found.
```

This prevents a malicious event payload from deleting a variant from another product.

## UI Requirement

In the product variants table, make the existing `remove` button functional.

Button label:

```text
Remove
```

Recommended event:

```text
delete-product-variant
```

Example markup:

```heex
<button
  type="button"
  class="btn btn-xs btn-error"
  phx-click="delete-product-variant"
  phx-value-id={product_variant.id}
  data-confirm="Remove this product variant?"
>
  Remove
</button>
```

Use the project’s existing confirmation pattern if available.

## Confirmation Requirement

Deleting a product variant should require confirmation.

Confirmation message:

```text
Remove this product variant?
```

If the project has a standard modal confirmation component, use it.

If not, using `data-confirm` or existing Phoenix confirmation behavior is acceptable.

The goal is to prevent accidental deletion.

## Delete Behavior

When admin confirms delete:

```text
delete product variant
reload current product with variants
update variants table
show success flash
```

Recommended success flash:

```text
Product variant removed successfully.
```

If delete fails:

```text
do not crash
show error flash
keep current page usable
```

Recommended error flash:

```text
Could not remove product variant.
```

## Refresh Behavior After Delete

After successful delete:

```text
reload current product with variants
update variants table
```

Variants should still be ordered by:

```text
display_order ascending
inserted_at ascending
```

Do not require a full page reload.

LiveView assign update is preferred.

## Empty State Behavior

If the deleted variant was the last variant:

```text
variants table should show No variants
```

The page should not crash.

The `New variant` button from Task `039-06` should remain visible.

## Edit Dialog Interaction

If the edit dialog is open for a variant and that same variant is deleted somehow:

```text
close edit dialog safely
clear selected_product_variant
reload variants
```

In normal UI flow, this may not happen, but the LiveView should avoid stale selected variant state after delete.

## Product Variant Display Order After Delete

This task does not need to reorder remaining variants.

Example:

```text
before delete:
variant A display_order = 0
variant B display_order = 1
variant C display_order = 2

delete variant B

after delete:
variant A display_order = 0
variant C display_order = 2
```

This is acceptable.

Do not implement automatic variant reorder in this task.

A future task can normalize variant order if needed.

## Tests

Add or update Products context tests.

### Context Tests

Test:

```text
delete_product_variant/1 deletes product variant
delete_product_variant/1 returns deleted variant
delete_product_variant/1 does not delete product
delete_product_variant/1 does not delete other variants
```

If `sale_order_items` already exists, add tests for snapshot safety:

```text
deleting product variant does not delete sale_order_item
deleting product variant preserves sale_order_item snapshot fields
deleting product variant sets sale_order_items.product_variant_id to nil if FK exists and is configured that way
```

Only add these sale order tests if sale order tables already exist.

## LiveView Tests

Add tests for:

```text
/admin/products/:id
```

### Rendering Tests

Test:

```text
variant row renders Remove button
Remove button has delete-product-variant event
Remove button has confirmation
```

### Delete Success Test

Test:

```text
admin clicks Remove for a variant
product variant is deleted
success flash is shown
variant disappears from variants table
```

### Delete Last Variant Test

Test:

```text
admin removes the last variant
No variants is shown
page does not crash
```

### Product Ownership Test

Test:

```text
deleting variant from current product works
attempting to delete variant from another product is ignored or shows error
variant from another product is not deleted
```

### Delete Failure Test

If practical, test:

```text
delete failure shows error flash
page remains usable
```

### Create/Edit Still Work

Verify existing behavior remains intact:

```text
New variant button still works
Edit variant button still works
```

Do not over-test if covered elsewhere, but make sure delete does not break the product detail page.

## Authorization Tests

If earlier tasks already cover product detail authorization, do not duplicate too much.

At minimum, verify:

```text
admin can use Remove button
customer cannot access /admin/products/:id
system cannot access /admin/products/:id
anonymous user redirects to login
```

## Acceptance Criteria

The task is complete when:

```text
mix test passes
/admin/products/:id still works
variant rows have functional Remove button
Remove button asks for confirmation
admin can delete product variant
deleted variant is removed from database
deleted variant disappears from variants table
success flash appears after delete
delete failure shows error flash
deleting a variant from another product is rejected or ignored safely
product with no variants shows No variants
deleting last variant does not crash page
delete_product_variant/1 exists in Products context
hard delete is used
is_deleted is not added
deleted_at is not added
sale_order_items are not deleted when variant is deleted
sale_order_item snapshot strategy remains the historical source of truth
no bulk delete behavior is implemented
no restore behavior is implemented
```

## Notes

Keep this task focused on deleting product variants.

Business decision:

```text
Product variants are allowed to be hard deleted.
Sale order history is protected by sale_order_items snapshots.
No soft delete is needed.
```

Future tasks can add:

```text
variant display_order normalization
bulk variant actions
sale order item implementation with nullable product_variant_id
inventory movement handling
```

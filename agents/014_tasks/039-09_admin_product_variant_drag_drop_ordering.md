# Task 039-09: Admin Product Variant Drag-Drop Ordering

## Filename

`039-09_admin_product_variant_drag_drop_ordering.md`

## Goal

Add drag-drop ordering for product variants on the admin product detail page.

Target page:

```text
/admin/products/:id
```

In the product variants list/table, admin should be able to drag product variant rows to change their order.

After drag-drop, update:

```text
product_variants.display_order
```

The display order should start from:

```text
0
```

and continue sequentially:

```text
0, 1, 2, 3, ...
```

## Background

Previous tasks:

```text
039-01 -> admin product detail shell
039-02 -> product variants readonly table
039-06 -> create product variant dialog
039-07 -> edit product variant dialog
039-08 -> delete product variant
```

This task adds ordering behavior to the existing product variants table.

## Route

Use the existing admin product detail route:

```text
/admin/products/:id
```

Do not create a new route.

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
Task 039-07: edit product variant dialog exists
Task 039-08: delete product variant exists
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

Implement drag-drop ordering for product variants.

Likely files:

```text
lib/ca_heo_shop/products.ex
lib/ca_heo_shop_web/live/admin/product_live/show.ex
lib/ca_heo_shop_web/live/admin/product_live/show.html.heex
assets/js/app.js
test/ca_heo_shop/products_test.exs
test/ca_heo_shop_web/live/admin/product_live/show_test.exs
```

Actual file names may differ depending on the current project structure.

## Do Not Implement

Do not implement:

```text
create product variant
edit product variant
delete product variant
variant image upload
variant image picker
stock adjustment history
inventory movements
bulk variant actions
```

Create, edit, and delete behavior should continue working from previous tasks.

This task only changes product variant ordering.

## UI Requirement

The product variants table should support drag-drop row ordering.

Each variant row should still show existing fields, such as:

```text
variant name
production_cost
selling_price
stock_quantity
image_filename
display_order
actions
```

After reorder succeeds:

```text
the row order updates
display_order values update
edit button still works
remove button still works
```

## Drag Handle Requirement

Add a clear drag handle to each product variant row.

Recommended label/icon:

```text
Drag
```

or:

```text
☰
```

The handle should make it obvious that the row can be moved.

Recommended table column placement:

```text
first column -> drag handle
second column -> display_order
last column -> actions
```

Do not make the whole row accidentally clickable if it conflicts with edit/remove buttons.

## Products Context Requirement

Update:

```text
lib/ca_heo_shop/products.ex
```

Add a context function:

```elixir
reorder_product_variants(product_id, ordered_variant_ids)
```

Expected behavior:

```text
accept product_id
accept ordered list of product_variant ids
validate all ids belong to the given product
validate the list contains exactly all variants for the product
update display_order sequentially from 0
run updates inside a transaction
return {:ok, product_variants} on success
return {:error, reason} on failure
```

Example:

```elixir
Products.reorder_product_variants(product.id, ["12", "9", "15"])
```

Expected result:

```text
variant 12 -> display_order 0
variant 9  -> display_order 1
variant 15 -> display_order 2
```

## Ownership Safety Requirement

Only reorder variants that belong to the given product.

If the ordered ids contain a variant from another product:

```text
return error
do not update any display_order
```

If the ordered ids are missing a variant that belongs to the product:

```text
return error
do not update any display_order
```

If the ordered ids contain an unknown variant id:

```text
return error
do not update any display_order
```

If the ordered ids contain duplicates:

```text
return error
do not update any display_order
```

This protects against bad or malicious client-side payloads.

## Transaction Requirement

The reorder operation must be atomic.

Use either:

```elixir
Ecto.Multi
```

or:

```elixir
Repo.transaction(fn -> ... end)
```

If any update fails:

```text
rollback all changes
```

Do not allow partial reorder updates.

## Suggested Context Implementation Shape

Recommended high-level flow:

```elixir
def reorder_product_variants(product_id, ordered_variant_ids) do
  normalized_ids = normalize_ids(ordered_variant_ids)

  Repo.transaction(fn ->
    product_variants =
      ProductVariant
      |> where([pv], pv.product_id == ^product_id)
      |> order_by([pv], asc: pv.display_order, asc: pv.inserted_at)
      |> Repo.all()

    validate_reorder_ids!(product_variants, normalized_ids)

    normalized_ids
    |> Enum.with_index()
    |> Enum.each(fn {id, display_order} ->
      product_variant = Enum.find(product_variants, &(&1.id == id))

      product_variant
      |> ProductVariant.changeset(%{display_order: display_order})
      |> Repo.update!()
    end)

    ProductVariant
    |> where([pv], pv.product_id == ^product_id)
    |> order_by([pv], asc: pv.display_order, asc: pv.inserted_at)
    |> Repo.all()
  end)
end
```

Adjust implementation to match the project style.

Prefer clean tagged tuples:

```elixir
{:ok, product_variants}
{:error, :invalid_product_variant_order}
```

## ID Normalization Requirement

`ordered_variant_ids` may come from LiveView params as strings.

Normalize safely.

Example accepted inputs:

```elixir
["3", "1", "2"]
[3, 1, 2]
```

Invalid ids should return an error.

Do not raise unhandled exceptions for bad client payloads.

## LiveView Event Requirement

Add a LiveView event to receive the new order.

Recommended event name:

```text
reorder-product-variants
```

Expected payload:

```elixir
%{"ids" => ordered_variant_ids}
```

or:

```elixir
%{"variant_ids" => ordered_variant_ids}
```

Use whichever shape is easiest for the JS hook.

The handler should call:

```elixir
Products.reorder_product_variants(product.id, ordered_variant_ids)
```

On success:

```text
reload or update product variants assign
update variants table
show success flash if useful
```

Recommended success flash:

```text
Product variant order updated.
```

On error:

```text
do not change UI state permanently
show error flash
```

Recommended error flash:

```text
Could not reorder product variants.
```

## JavaScript Hook Requirement

Implement a small JS hook for drag-drop ordering.

Recommended hook name:

```text
ProductVariantSortable
```

The hook should:

```text
allow dragging variant rows
collect ordered variant ids after drop
push event to LiveView
```

Example markup idea:

```heex
<tbody id="product-variants-sortable" phx-hook="ProductVariantSortable">
  <tr id={"product-variant-#{product_variant.id}"} data-variant-id={product_variant.id}>
    ...
  </tr>
</tbody>
```

After reorder:

```javascript
this.pushEvent("reorder-product-variants", {ids: orderedIds})
```

## Dependency Choice

Prefer native HTML5 drag/drop if practical.

If the project already uses a drag-drop library, reuse it.

If adding a new dependency such as SortableJS, document it clearly and keep the implementation small.

Recommended first direction:

```text
use native browser drag/drop
avoid adding a new dependency unless necessary
```

## DOM ID Requirement

Each variant row must have a stable DOM id.

Recommended:

```text
product-variant-<id>
```

Example:

```heex
<tr id={"product-variant-#{product_variant.id}"} data-variant-id={product_variant.id}>
  ...
</tr>
```

Stable ids are important for LiveView updates and JS hook behavior.

## Existing Buttons Requirement

The product variant row actions should continue to work.

Existing buttons from previous tasks:

```text
Edit
Remove
```

After this task:

```text
Edit still opens edit dialog
Remove still deletes variant after confirmation
Drag-drop should not trigger edit
Drag-drop should not trigger remove
```

Do not break create/edit/delete variant behavior.

## Display Order UI Requirement

The visible `display_order` value should update after reorder.

Example after moving a variant to the top:

```text
display_order = 0
```

The table order and displayed order should match.

## Product Detail Reload Requirement

After successful reorder, reload the current product detail data or update assigns so variants are fresh.

Expected variant order:

```text
display_order ascending
inserted_at ascending
```

The page should not require full browser refresh.

LiveView assign update is preferred.

## Empty State

If the product has no variants:

```text
show No variants
do not initialize drag-drop behavior in a way that crashes
```

If the product has one variant:

```text
drag-drop can be inactive
page should not crash
```

## Error Handling

If reorder fails:

```text
show error flash
keep or reload previous order
do not crash
```

Recommended flash:

```text
Could not reorder product variants.
```

## Tests

Add or update Products context tests.

### Context Success Tests

Test:

```text
reorder_product_variants/2 updates display_order from 0
reorder_product_variants/2 returns variants in new order
reorder_product_variants/2 works with string ids
reorder_product_variants/2 keeps variants under the same product
```

Example:

```text
before:
variant A display_order = 0
variant B display_order = 1
variant C display_order = 2

input:
[variant C id, variant A id, variant B id]

after:
variant C display_order = 0
variant A display_order = 1
variant B display_order = 2
```

### Context Safety Tests

Test:

```text
reorder_product_variants/2 rejects variant id from another product
reorder_product_variants/2 rejects unknown variant id
reorder_product_variants/2 rejects missing variant id
reorder_product_variants/2 rejects duplicate variant id
reorder_product_variants/2 does not partially update on error
```

### LiveView Rendering Tests

Test page renders:

```text
drag handle
product variant rows with data-variant-id
stable DOM ids for product variant rows
```

### LiveView Event Tests

Test:

```text
reorder-product-variants event updates variant order
reorder-product-variants event updates visible display_order
invalid reorder event shows error flash
invalid reorder event does not crash
```

If LiveView test cannot fully simulate browser drag-drop, test the LiveView event directly.

### Existing Behavior Tests

Verify existing behavior still works:

```text
New variant button still works
Edit variant button still works
Remove variant button still works
```

Do not over-test if previous tasks already cover these, but make sure drag-drop markup does not break the action buttons.

## Acceptance Criteria

The task is complete when:

```text
mix test passes
/admin/products/:id still works
product variants table supports drag-drop ordering
each variant row has a drag handle
each variant row has stable DOM id
each variant row has data-variant-id
drag-drop sends ordered variant ids to LiveView
Products.reorder_product_variants/2 exists
Products.reorder_product_variants/2 validates product ownership
Products.reorder_product_variants/2 rejects duplicate ids
Products.reorder_product_variants/2 rejects missing ids
Products.reorder_product_variants/2 rejects unknown ids
Products.reorder_product_variants/2 updates display_order from 0
Products.reorder_product_variants/2 updates inside a transaction
displayed variant row order updates after reorder
displayed display_order values update after reorder
product with no variants does not crash
product with one variant does not crash
New variant behavior still works
Edit variant behavior still works
Remove variant behavior still works
no new create/edit/delete behavior is added in this task
no stock adjustment history is implemented
no inventory movement behavior is implemented
```

## Notes

Keep this task focused on product variant ordering only.

This task should not create, edit, or delete variants.

Future tasks can add:

```text
variant stock adjustment
inventory movement tracking
variant image picker
bulk variant actions
variant table sorting/filtering
```

# Task 039-05: Admin Product Image Drag-Drop Ordering

## Filename

`039-05_admin_product_image_drag_drop_ordering.md`

## Goal

Add drag-drop ordering for product images on the admin product detail page.

Target page:

```text
/admin/products/:id
```

Admin should be able to drag product images in the product images list to change their order.

After drag-drop, update:

```text
product_images.display_order
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
039-01 -> created admin product detail shell
039-02 -> added readonly product variants table
039-03 -> added image preview and thumbnail list
039-04 -> added click-to-select image preview behavior
```

This task adds ordering behavior to the existing product images list.

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

can access:

```text
/admin/products/:id
```

If Task 035 already protects `/admin/*`, reuse that behavior.

Do not add new authorization logic in this task.

## Dependencies

This task depends on:

```text
Task 031: product_images table exists
Task 035: admin route authorization exists
Task 039-01: admin product detail shell exists
Task 039-02: product variants readonly table exists
Task 039-03: product image preview and thumbnail list exists
Task 039-04: product image preview selection exists
```

Expected schemas:

```text
CaHeoShop.Products.Product
CaHeoShop.Products.ProductImage
```

Expected ProductImage fields:

```text
id
product_id
filename
display_order
has_thumbnail
inserted_at
updated_at
```

## Scope

Implement drag-drop image ordering for product images.

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
real image delete behavior
image upload
image file deletion
thumbnail generation
image edit form
product variant behavior
variant image behavior
```

This task only changes the order of existing product images.

## UI Requirement

The product images list should support drag-drop.

The admin should be able to reorder images visually.

The list should still show:

```text
thumbnail or thumbnail placeholder
filename
display_order
has_thumbnail status
selected state
```

After reorder succeeds, the visible order should update.

## Drag Handle Requirement

Add a clear drag handle to each image item.

Recommended label/icon:

```text
Drag
```

or:

```text
☰
```

Use existing DaisyUI/admin styling.

The handle should make it obvious that the row/item can be moved.

## Image Display Rule

All images displayed directly in the product detail page must still use thumbnails.

This includes:

```text
image preview
product images list
```

Do not render original images directly inside the page.

The original image should still only be opened through:

```text
View original
```

## Products Context Requirement

Update:

```text
lib/ca_heo_shop/products.ex
```

Add a context function:

```elixir
reorder_product_images(product_id, ordered_image_ids)
```

Expected behavior:

```text
accept product_id
accept ordered list of product_image ids
validate all ids belong to the given product
update display_order sequentially from 0
run updates inside a transaction
return {:ok, product_images} on success
return {:error, reason} on failure
```

Recommended function signature:

```elixir
def reorder_product_images(product_id, ordered_image_ids)
```

`ordered_image_ids` may contain strings from LiveView params.

Normalize them safely.

Example:

```elixir
Products.reorder_product_images(product.id, ["12", "9", "15"])
```

should result in:

```text
image 12 -> display_order 0
image 9  -> display_order 1
image 15 -> display_order 2
```

## Ownership Safety Requirement

Only reorder images that belong to the given product.

If the ordered ids contain an image from another product:

```text
return error
do not update any display_order
```

If the ordered ids are missing an image that belongs to the product:

```text
return error
do not update any display_order
```

If the ordered ids contain an unknown image id:

```text
return error
do not update any display_order
```

If the ordered ids contain duplicates:

```text
return error
do not update any display_order
```

This protects against bad client-side payloads.

## Transaction Requirement

The reorder operation must be atomic.

Use:

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
def reorder_product_images(product_id, ordered_image_ids) do
  normalized_ids = normalize_ids(ordered_image_ids)

  Repo.transaction(fn ->
    product_images =
      ProductImage
      |> where([pi], pi.product_id == ^product_id)
      |> order_by([pi], asc: pi.display_order, asc: pi.inserted_at)
      |> Repo.all()

    validate_reorder_ids!(product_images, normalized_ids)

    normalized_ids
    |> Enum.with_index()
    |> Enum.each(fn {id, display_order} ->
      product_image = Enum.find(product_images, &(&1.id == id))

      product_image
      |> ProductImage.changeset(%{display_order: display_order})
      |> Repo.update!()
    end)

    ProductImage
    |> where([pi], pi.product_id == ^product_id)
    |> order_by([pi], asc: pi.display_order, asc: pi.inserted_at)
    |> Repo.all()
  end)
end
```

Adjust implementation to match project style.

Prefer returning clean tagged tuples:

```elixir
{:ok, product_images}
{:error, :invalid_product_image_order}
```

## LiveView Event Requirement

Add a LiveView event to receive the new order.

Recommended event name:

```text
reorder-product-images
```

Expected payload:

```elixir
%{"ids" => ordered_image_ids}
```

or:

```elixir
%{"image_ids" => ordered_image_ids}
```

Use whichever shape is easiest for the JS hook.

The handler should call:

```elixir
Products.reorder_product_images(product.id, ordered_image_ids)
```

On success:

```text
reload or update product_images assign
keep selected image if it still exists
update selected image with fresh struct
show success flash if useful
```

On error:

```text
do not change UI state permanently
show error flash
```

Recommended error flash:

```text
Could not reorder product images.
```

## Selected Image Behavior After Reorder

If the currently selected image still exists after reorder:

```text
keep it selected
```

Its position in the image list should change according to the new order.

If for some unexpected reason selected image is no longer found:

```text
fallback to display_order = 0 image
or first ordered image
or nil
```

This mirrors the selection rule from Task `039-04`.

## JavaScript Hook Requirement

Implement a small JS hook for drag-drop ordering.

Recommended hook name:

```text
ProductImageSortable
```

The hook should:

```text
allow dragging image items
collect ordered image ids after drop
push event to LiveView
```

Example markup idea:

```heex
<div id="product-images-sortable" phx-hook="ProductImageSortable">
  <div data-image-id={product_image.id}>
    ...
  </div>
</div>
```

After reorder:

```javascript
this.pushEvent("reorder-product-images", {ids: orderedIds})
```

## Dependency Choice

Prefer a simple implementation with native HTML5 drag/drop if the list is simple.

If the project already uses a drag-drop library, reuse it.

If adding a new dependency such as SortableJS, document it clearly and keep the implementation small.

Recommended first direction:

```text
use native browser drag/drop if practical
avoid adding a new dependency unless necessary
```

## DOM ID Requirement

Each image item must have a stable DOM id.

Recommended:

```text
product-image-<id>
```

Example:

```heex
<div id={"product-image-#{product_image.id}"} data-image-id={product_image.id}>
  ...
</div>
```

Stable ids are important for LiveView updates and JS hook behavior.

## LiveView Update Requirement

After reorder, product images should be displayed in the new order.

The LiveView should update assigns.

Recommended assigns:

```elixir
:product
:selected_product_image
```

or, if product images are assigned separately:

```elixir
:product_images
:selected_product_image
```

Keep the existing style from Tasks `039-03` and `039-04`.

## Display Order UI Requirement

The visible `display_order` value should update after reorder.

Example after moving an image to the top:

```text
display_order = 0
```

The list order and displayed order should match.

## Empty State

If the product has no images:

```text
show No product images
do not initialize drag-drop behavior in a way that crashes
```

If the product has one image:

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
Could not reorder product images.
```

If reorder succeeds, success flash is optional.

If shown, use:

```text
Product image order updated.
```

## Tests

Add or update Products context tests.

### Context Success Tests

Test:

```text
reorder_product_images/2 updates display_order from 0
reorder_product_images/2 returns images in new order
reorder_product_images/2 works with string ids
reorder_product_images/2 keeps images under the same product
```

Example:

```text
before: image_a order 0, image_b order 1, image_c order 2
input: [image_c.id, image_a.id, image_b.id]
after: image_c order 0, image_a order 1, image_b order 2
```

### Context Safety Tests

Test:

```text
reorder_product_images/2 rejects image id from another product
reorder_product_images/2 rejects unknown image id
reorder_product_images/2 rejects missing image id
reorder_product_images/2 rejects duplicate image id
reorder_product_images/2 does not partially update on error
```

### LiveView Rendering Tests

Test page renders:

```text
drag handle
product image items with data-image-id
stable DOM ids for product images
```

### LiveView Event Tests

Test:

```text
reorder-product-images event updates image order
reorder-product-images event updates visible display_order
selected image remains selected after reorder
invalid reorder event shows error flash
invalid reorder event does not crash
```

If LiveView test cannot fully simulate browser drag-drop, test the LiveView event directly.

## Acceptance Criteria

The task is complete when:

```text
mix test passes
/admin/products/:id still works
product images list supports drag-drop ordering
each product image item has a drag handle
each product image item has stable DOM id
each product image item has data-image-id
drag-drop sends ordered image ids to LiveView
Products.reorder_product_images/2 exists
Products.reorder_product_images/2 validates product ownership
Products.reorder_product_images/2 rejects duplicate ids
Products.reorder_product_images/2 rejects missing ids
Products.reorder_product_images/2 rejects unknown ids
Products.reorder_product_images/2 updates display_order from 0
Products.reorder_product_images/2 updates inside a transaction
displayed image list order updates after reorder
displayed display_order values update after reorder
selected image remains selected after reorder
all displayed images still use thumbnails
original image is only opened through View original
product with no images does not crash
product with one image does not crash
real delete behavior is not implemented
image upload is not implemented
```

## Notes

Keep this task focused on image ordering only.

This task should not delete, upload, or edit images.

Future tasks can add:

```text
039-06 real product image delete behavior
product image upload
thumbnail regeneration
image metadata editing
```

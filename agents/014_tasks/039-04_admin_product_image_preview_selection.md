# Task 039-04: Admin Product Image Preview Selection

## Filename

`039-04_admin_product_image_preview_selection.md`

## Goal

Add image selection behavior to the admin product detail page.

Target page:

```text
/admin/products/:id
```

When admin clicks an image in the product images list, the image preview panel should update to show that selected image.

This task builds on `039-03`, which already added:

```text
image preview panel
selected image filename
copy filename button
static delete button
view original button
product images thumbnail list
```

## Background

The admin product detail page already shows product images.

Before this task, the preview image uses the first image by order:

```text
display_order = 0
```

or the first available image.

This task allows the admin to choose which product image is currently previewed.

## Route

Use the existing route:

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

Do not add new authorization behavior in this task.

## Dependencies

This task depends on:

```text
Task 031: product_images table exists
Task 035: admin route authorization exists
Task 039-01: admin product detail shell exists
Task 039-02: product variants readonly table exists
Task 039-03: product image preview and thumbnail list exists
```

Expected schemas:

```text
CaHeoShop.Products.Product
CaHeoShop.Products.ProductImage
```

Expected `ProductImage` fields:

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

Add LiveView state and event handling for selecting a product image.

Likely files:

```text
lib/ca_heo_shop_web/live/admin/product_live/show.ex
lib/ca_heo_shop_web/live/admin/product_live/show.html.heex
test/ca_heo_shop_web/live/admin/product_live/show_test.exs
```

Actual file names may differ depending on the current project structure.

## Do Not Implement

Do not implement:

```text
drag-drop image ordering
real delete image behavior
image upload
image file deletion
thumbnail generation
image edit form
image reorder database update
```

This task only updates the selected preview image in the LiveView.

## Selection Behavior

Each image in the product images list should be clickable.

When admin clicks an image item:

```text
selected image changes
preview thumbnail changes
filename under preview changes
copy button data changes
view original link changes
selected item visual state changes
```

The selected image should be tracked in LiveView assigns.

Recommended assign:

```elixir
:selected_product_image
```

or:

```elixir
:selected_product_image_id
```

Preferred:

```elixir
:selected_product_image
```

because the template needs:

```text
filename
has_thumbnail
thumbnail URL
original URL
```

## Initial Selected Image Rule

On page load, keep the same behavior from Task `039-03`.

Initial selected image should be:

```text
1. ProductImage with display_order = 0, if it exists.
2. Otherwise first image from ordered product_images list.
3. Otherwise nil.
```

Recommended helper:

```elixir
defp default_selected_product_image(product) do
  Enum.find(product.product_images, &(&1.display_order == 0)) ||
    List.first(product.product_images)
end
```

## Click Event Requirement

Add a LiveView event.

Recommended event name:

```text
select-product-image
```

Example markup:

```heex
<button
  type="button"
  phx-click="select-product-image"
  phx-value-id={product_image.id}
>
  ...
</button>
```

Event handler:

```elixir
def handle_event("select-product-image", %{"id" => id}, socket) do
  selected_product_image =
    Enum.find(socket.assigns.product.product_images, fn product_image ->
      to_string(product_image.id) == id
    end)

  {:noreply, assign(socket, :selected_product_image, selected_product_image)}
end
```

Only allow selecting images that belong to the current product and are already loaded in:

```elixir
socket.assigns.product.product_images
```

Do not query by arbitrary image id without checking product ownership.

## Invalid Selection Behavior

If the image id does not belong to the current product, ignore the event safely.

Expected behavior:

```text
do not crash
do not change selected image
do not raise exception
```

Recommended implementation:

```elixir
case Enum.find(socket.assigns.product.product_images, &(to_string(&1.id) == id)) do
  nil ->
    {:noreply, socket}

  product_image ->
    {:noreply, assign(socket, :selected_product_image, product_image)}
end
```

## Preview Panel Update Requirement

When selected image changes, update:

```text
preview thumbnail
filename
copy filename button
view original link
```

The preview must still follow thumbnail rules:

```text
has_thumbnail = true  -> show thumbnail
has_thumbnail = false -> show thumbnail placeholder
```

Do not render the original image directly in the preview.

The original image should only be available through:

```text
View original
```

## Product Images List Selected State

The selected image item should be visually distinguishable.

Examples:

```text
border-primary
ring
bg-base-200
selected badge
```

Use existing DaisyUI/admin styling.

Recommended visible label:

```text
Selected
```

or an icon/border.

The selected state should be based on:

```text
selected_product_image.id
```

## Copy Button Update Requirement

The copy button should copy the filename of the currently selected image.

When selection changes:

```text
data-copy-text changes to selected image filename
```

Do not copy:

```text
thumbnail URL
original URL
image id
```

Only copy:

```text
filename
```

If no image is selected, the copy button should be disabled or hidden.

## View Original Update Requirement

The `View original` button/link should point to the original URL of the currently selected image.

When selection changes:

```text
href changes to selected image original URL
```

The link should open in a new tab:

```html
target="_blank"
rel="noopener noreferrer"
```

If no image is selected, the button should be disabled or hidden.

## Static Delete Button Requirement

Keep the delete button static.

The delete button can still appear for the selected image, but it must not delete anything.

Preferred:

```heex
<button type="button" class="btn btn-error btn-sm" disabled>
  Delete
</button>
```

Do not add:

```text
phx-click
data-confirm
href
JS command
```

Real delete belongs to a future task.

## Thumbnail Rule

All images displayed directly on the page must use thumbnails.

This includes:

```text
preview image
product images list
```

If selected image has no thumbnail:

```text
show thumbnail placeholder
still show filename
still allow View original
```

Do not use original image as fallback inside the page UI.

## Empty State

If product has no images:

```text
selected_product_image = nil
preview shows No image
product images list shows No product images
copy button disabled or hidden
view original button disabled or hidden
delete button disabled
```

The page must not crash.

## Tests

Add or update LiveView tests for:

```text
/admin/products/:id
```

### Initial Selection Tests

Test:

```text
initial preview uses ProductImage with display_order = 0
initial preview falls back to first ordered image when no display_order = 0 exists
initial preview shows No image when product has no images
```

### Click Selection Tests

Test:

```text
clicking a product image updates preview image
clicking a product image updates filename under preview
clicking a product image updates copy button data-copy-text
clicking a product image updates View original href
clicking a product image marks that item as selected
```

### Ownership Safety Tests

Test:

```text
select-product-image ignores image id that does not belong to current product
invalid image id does not crash the page
```

### Thumbnail Tests

Test:

```text
selected preview uses thumbnail path when has_thumbnail = true
selected preview shows placeholder when has_thumbnail = false
selected preview does not render original image directly
View original still links to original image
```

### Empty State Tests

Test:

```text
product without images renders No image
product without images renders No product images
copy button is disabled or absent
view original button is disabled or absent
delete button is disabled
```

## Acceptance Criteria

The task is complete when:

```text
mix test passes
/admin/products/:id still works
product images list items are clickable
clicking product image updates preview
clicking product image updates filename under preview
clicking product image updates copy button data-copy-text
clicking product image updates View original link
selected product image is visually distinguishable
initial selected image uses display_order = 0 when available
initial selected image falls back to first ordered image
product with no images does not crash
invalid image selection does not crash
invalid image selection does not select image from another product
all displayed images still use thumbnails
original image is only opened through View original
delete button remains static/disabled
no drag-drop ordering is implemented
no real delete behavior is implemented
no image upload is implemented
```

## Notes

Keep this task focused on preview selection only.

Future tasks can add:

```text
039-05 product image drag-drop ordering
039-06 real product image delete behavior
product image upload
thumbnail regeneration
image metadata editing
```

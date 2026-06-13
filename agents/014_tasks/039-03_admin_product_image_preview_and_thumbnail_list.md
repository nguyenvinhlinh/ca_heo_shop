# Task 039-03: Admin Product Image Preview And Thumbnail List

## Filename

`039-03_admin_product_image_preview_and_thumbnail_list.md`

## Goal

Add the first version of the product image area to the admin product detail page.

Target page:

```text id="y4zxii"
/admin/products/:id
```

This task adds the right-side image panel.

The panel should include:

```text id="7ibh3q"
image preview area
selected image filename
copy filename to clipboard button
static delete button
view original image button/link
readonly product images thumbnail list
```

All images displayed directly on this page must use thumbnails.

The original image should only be opened through the:

```text id="0jkm96"
View original
```

button/link.

## Background

Task `039-01` created the admin product detail shell.

Task `039-02` added the readonly product variants table on the left side.

This task adds the first readonly image UI on the right side.

Later tasks will add:

```text id="c1sjo4"
click thumbnail to update preview
drag-drop image ordering
real delete image behavior
image upload
```

## Route

Use the existing admin product detail route:

```text id="6pjfsq"
/admin/products/:id
```

Do not create a new route for this task.

## Authorization Requirement

Only users with role:

```text id="2o8v8u"
admin
```

can access:

```text id="dja9dn"
/admin/products/:id
```

If Task 035 already protects `/admin/*`, reuse that behavior.

Do not add new authorization behavior in this task.

## Dependencies

This task depends on:

```text id="3r88jy"
Task 031: product_images table exists
Task 035: admin route authorization exists
Task 039-01: admin product detail shell exists
Task 039-02: product variants readonly table exists
```

Expected schemas:

```text id="hrkx5s"
CaHeoShop.Products.Product
CaHeoShop.Products.ProductImage
```

Expected association on `Product`:

```elixir id="gifrpf"
has_many :product_images, CaHeoShop.Products.ProductImage
```

Expected ProductImage fields:

```text id="cmotfh"
id
product_id
filename
display_order
has_thumbnail
inserted_at
updated_at
```

If `has_thumbnail` does not exist yet, add it in the earlier product image task before doing this task.

## Scope

Update the admin product detail page to show product images.

Likely files:

```text id="hd6ng9"
lib/ca_heo_shop/products.ex
lib/ca_heo_shop_web/live/admin/product_live/show.ex
lib/ca_heo_shop_web/live/admin/product_live/show.html.heex
lib/ca_heo_shop_web/components/core_components.ex
assets/js/app.js
test/ca_heo_shop/products_test.exs
test/ca_heo_shop_web/live/admin/product_live/show_test.exs
```

Actual files may differ depending on the current project structure.

## Do Not Implement

Do not implement:

```text id="wkdvf4"
click thumbnail to update preview
drag-drop image ordering
real delete image behavior
image upload
image file deletion
thumbnail generation
image edit form
image reorder database update
```

The delete button in this task is only a static placeholder.

The product images list is readonly.

## Layout Requirement

The admin product detail page should use a two-column layout.

Recommended layout:

```text id="9tgc7d"
left column:
  product information
  product variants table

right column:
  image preview panel
  product images thumbnail list
```

The right column should contain this task’s image UI.

Use existing admin layout and DaisyUI styling.

## Product Images Context Requirement

Update:

```text id="d9yu70"
lib/ca_heo_shop/products.ex
```

Ensure the admin product detail loader preloads product images.

Recommended function:

```elixir id="n9jo2w"
get_admin_product!(id)
```

Expected preloads after this task:

```text id="ji58dz"
collection
product_variants
product_images
```

Product images should be ordered by:

```text id="2zlrql"
display_order ascending
inserted_at ascending
```

Recommended helper:

```elixir id="y9ekjz"
defp product_images_order_query do
  from pi in ProductImage,
    order_by: [asc: pi.display_order, asc: pi.inserted_at]
end
```

Recommended preload shape:

```elixir id="suf2t2"
def get_admin_product!(id) do
  Product
  |> Repo.get!(id)
  |> Repo.preload([
    :collection,
    product_variants: product_variants_order_query(),
    product_images: product_images_order_query()
  ])
end
```

If `get_admin_product!/1` already exists, update it carefully.

## Selected Image Rule

This task does not implement user-driven image selection yet.

For now, the preview image should use the first product image by order.

Selection rule:

```text id="5j25jl"
1. Use the ProductImage with display_order = 0 if it exists.
2. If no display_order = 0 image exists, use the first image from the ordered product_images list.
3. If no product image exists, show No image.
```

Future task `039-04` will allow clicking thumbnails to update the selected preview image.

## Thumbnail Display Rule

All images displayed directly on the page must be thumbnails.

This includes:

```text id="hptq39"
image preview
product images list
```

Use thumbnail image URLs when:

```text id="jkz6so"
has_thumbnail = true
```

If `has_thumbnail = false`, do not display the original image as if it were a thumbnail.

Recommended fallback:

```text id="q7ne27"
show a thumbnail placeholder
```

Reason:

```text id="q65dli"
The page should not load large original images into the admin detail UI.
```

The original image can be opened only through:

```text id="dzcrq7"
View original
```

## Image URL Helpers

Use the existing project image path convention.

If helper functions already exist, reuse them.

Recommended helper names:

```elixir id="l34g3j"
product_image_original_path(product_image)
product_image_thumbnail_path(product_image)
```

or:

```elixir id="9376wq"
product_image_url(product_image)
product_image_thumbnail_url(product_image)
```

Do not invent a second thumbnail naming convention.

Use the same naming convention created by the thumbnail generator task.

If no helper exists, create a small helper in an appropriate web module.

The helper should return:

```text id="ihvo4j"
thumbnail URL for thumbnail rendering
original URL for View original link
```

## Image Preview Panel Requirements

Add a panel title:

```text id="tls1h1"
Image preview
```

If selected image exists and has thumbnail:

```text id="w0g4q5"
render thumbnail image
```

If selected image exists but has_thumbnail is false:

```text id="chx1q9"
render thumbnail placeholder
still show filename
still allow View original
```

If no image exists:

```text id="7k0ing"
show No image placeholder
do not show broken image
disable or hide image-specific buttons
```

Recommended preview image size:

```text id="ddvy50"
large square preview
aspect-square
object-cover
rounded box
```

Use admin template/DaisyUI classes where possible.

## Filename Display Requirement

Under the preview image, show the selected image filename.

If selected image exists:

```text id="1vj6q0"
show filename
```

If no image exists:

```text id="z52qx9"
show —
```

Long filenames must not break the layout.

Use truncation styling.

Recommended:

```text id="5ajxea"
truncate
min-w-0
break-all only if needed
```

The filename area must remain responsive.

## Copy Filename Button Requirement

Add a button next to the filename:

```text id="8s0yrx"
Copy
```

The button should copy the selected image filename to clipboard.

This is a frontend-only behavior.

Recommended approach:

```text id="lmv6y4"
small JS hook
navigator.clipboard.writeText(...)
```

Example hook name:

```text id="t72fs3"
CopyToClipboard
```

The button should store the filename in a data attribute.

Example shape:

```heex id="74t15v"
<button
  type="button"
  class="btn btn-xs"
  phx-hook="CopyToClipboard"
  data-copy-text={@selected_image.filename}
>
  Copy
</button>
```

Adjust to the existing JS hook style in the project.

If no image is selected, disable the copy button.

Do not copy thumbnail URL.

Do not copy original URL.

Only copy:

```text id="k8uwee"
filename
```

## Static Delete Button Requirement

Add a delete button under the preview.

Button label:

```text id="kgrfer"
Delete
```

This task must not implement actual delete behavior.

Preferred implementation:

```heex id="dnf4yq"
<button type="button" class="btn btn-error btn-sm" disabled>
  Delete
</button>
```

Do not add:

```text id="w7443w"
phx-click
data-confirm
href
JS command
```

Real delete belongs to a future task.

## View Original Button Requirement

Add a button or link:

```text id="aeyfa9"
View original
```

If selected image exists:

```text id="8m6o69"
link to original image URL
open in new tab
```

Recommended attributes:

```html id="3lb1ln"
target="_blank"
rel="noopener noreferrer"
```

If no image exists, disable or hide the button.

Important:

```text id="klxign"
View original uses the original image path, not the thumbnail path.
```

## Product Images List Requirement

Below the preview panel, show a product images list.

Section title:

```text id="l53pto"
Product images
```

The list should display all product images for the product.

Each item should show:

```text id="g558sy"
thumbnail or thumbnail placeholder
filename
display_order
has_thumbnail status
```

Required order:

```text id="96g4n4"
display_order ascending
inserted_at ascending
```

If a product image has thumbnail:

```text id="vlfase"
show thumbnail
```

If it does not have thumbnail:

```text id="cxfwdq"
show thumbnail placeholder
```

Do not show original image in the list.

## Product Images List UI

The list can be displayed as:

```text id="ios1io"
small table
compact cards
thumbnail grid
```

Recommended for this task:

```text id="g9bga5"
compact table or vertical list
```

Each row/item should show enough information for admin inspection.

Example item:

```text id="gk4bpf"
[thumbnail] 0  product-a.jpg  Thumbnail: yes
```

Do not implement click-to-select in this task.

Do not implement drag-drop in this task.

Those belong to later tasks.

## Empty State

If the product has no images, show:

```text id="u2wfz1"
No product images
```

The page must not crash when:

```text id="rs510v"
product has no images
product image filename is long
product image has_thumbnail = false
product image display_order is nil or 0
```

If `display_order` is required by schema, no need to support nil.

## Tests

Add or update Products context tests.

### Context Tests

Test:

```text id="25zv8g"
get_admin_product!/1 preloads product_images
get_admin_product!/1 orders product_images by display_order then inserted_at
get_admin_product!/1 still preloads collection
get_admin_product!/1 still preloads product_variants
```

### LiveView Rendering Tests

Add tests for:

```text id="yf0yrl"
/admin/products/:id
```

Test page renders:

```text id="qw4h8s"
Image preview section title
Product images section title
selected image filename
copy button
delete button
view original button
product image list
product image filename
product image display_order
product image has_thumbnail status
```

Test thumbnail behavior:

```text id="k4fsbt"
preview uses thumbnail path when has_thumbnail = true
image list uses thumbnail path when has_thumbnail = true
View original uses original image path
```

Test no-thumbnail behavior:

```text id="i1f2ry"
preview does not render original image when has_thumbnail = false
image list does not render original image when has_thumbnail = false
thumbnail placeholder is shown when has_thumbnail = false
View original still links to original image
```

Test empty state:

```text id="bbhuow"
product without images renders No product images
product without images renders No image preview placeholder
copy button is disabled or absent when no image exists
delete button is disabled when no image exists
view original button is disabled or absent when no image exists
```

Test long filename safety if practical:

```text id="yk7x92"
long filename is rendered without breaking page structure
```

### Static Delete Button Tests

Test:

```text id="eq5a30"
delete button is rendered
delete button is disabled
delete button does not have phx-click
```

### Copy Button Tests

If the project has JS hook tests, test the hook registration.

If not, test rendered markup:

```text id="sn79am"
copy button includes selected image filename in data-copy-text
```

## Acceptance Criteria

The task is complete when:

```text id="tphphw"
mix test passes
/admin/products/:id still works
/admin/products/:id shows right-side image preview panel
/admin/products/:id shows Product images section
get_admin_product!/1 preloads product_images
product_images are ordered by display_order then inserted_at
preview uses ProductImage with display_order = 0 when available
preview falls back to first ordered image when no display_order = 0 exists
preview shows No image when product has no images
all displayed images use thumbnails
original image is not rendered directly in preview
original image is not rendered directly in product images list
View original opens original image URL
filename is shown under preview image
filename display does not break layout
Copy button copies selected filename
Delete button is present but disabled/static
No real delete behavior is implemented
product images list shows all product images
product images list shows filename
product images list shows display_order
product images list shows has_thumbnail status
product with no images does not crash page
click thumbnail to update preview is not implemented
drag-drop image ordering is not implemented
image upload is not implemented
```

## Notes

Keep this task focused on readonly image display.

This task creates the visual foundation for product image management.

Future tasks can add:

```text id="i5kbks"
039-04 click product image thumbnail to update preview
039-05 drag-drop product image ordering
039-06 real product image delete behavior
product image upload
thumbnail regeneration
image metadata editing
```

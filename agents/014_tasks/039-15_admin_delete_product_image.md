# Task 039-15: Admin Delete Product Image

## Filename

`039-15_admin_delete_product_image.md`

## Goal

Add delete product image behavior to the admin product show page.

Target page:

```text
/admin/products/:id
```

In the `Image Preview` section, add logic so admin can delete the currently selected product image.

When deleting a product image:

```text
delete ProductImage database record
delete original image file
delete generated thumbnail file if it exists
refresh Product Images list
refresh Image Preview
```

This task uses hard delete.

Do not add soft delete fields.

## Background

Previous tasks:

```text
039-03 -> Product Image Preview and thumbnail list
039-04 -> Product Image Preview selection
039-05 -> Product Image drag-drop ordering
039-11 -> Upload original product image
039-13 -> ThumbnailGenerator applies to ProductImages
```

Product images are stored in:

```text
%{assets_path}/product_images
```

where:

```elixir
config :ca_heo_shop, :assets_path
```

Product image files are served through:

```text
/product_images/:filename
```

Product image original filename format:

```text
%{product_id}_%{uuid}.%{file_image_extension}
```

Example original image:

```text
12_550e8400-e29b-41d4-a716-446655440000.jpg
```

Example thumbnail image:

```text
12_550e8400-e29b-41d4-a716-446655440000_500x500px.jpg
```

## Route

Use the existing admin product show route:

```text
/admin/products/:id
```

Do not create a separate full page route for deleting product images.

## Authorization Requirement

Only users with role:

```text
admin
```

can delete product images.

If Task 035 already protects `/admin/*`, reuse that behavior.

Do not add new role or permission logic in this task.

## Dependencies

This task depends on:

```text
Task 031: product_images table exists
Task 035: admin route authorization exists
Task 039-03: Image Preview and Product Images list exist
Task 039-04: image selection behavior exists
Task 039-11: product image upload and /product_images/:filename exist
Task 039-13: product image thumbnail naming exists
```

Expected schemas:

```text
CaHeoShop.Products.Product
CaHeoShop.Products.ProductImage
```

Expected context:

```text
CaHeoShop.Products
```

Expected storage config:

```elixir
config :ca_heo_shop, :assets_path
```

Expected product image directory:

```text
%{assets_path}/product_images
```

## Scope

Implement delete behavior for the selected product image in the `Image Preview` section.

Likely files:

```text
lib/ca_heo_shop/products.ex
lib/ca_heo_shop/products/product_image.ex
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
is_deleted
deleted_at
image archive
bulk delete
undo delete
image replacement
image upload
thumbnail generation
manual regenerate thumbnail
delete product
```

This task only deletes one selected product image.

## UI Requirement

In the `Image Preview` section, there should be a delete button.

Recommended label:

```text
Delete image
```

or:

```text
Delete
```

The button should delete the currently selected product image.

Recommended placement:

```text
Image Preview
  preview image
  filename
  copy filename button
  view original link
  delete image button
```

If no image is selected:

```text
disable delete button
```

or do not render it.

## Confirmation Requirement

Deleting a product image should require confirmation.

Recommended confirmation message:

```text
Delete this product image?
```

If the project has a standard confirmation modal, use it.

Otherwise, using the existing LiveView/Phoenix confirmation style is acceptable.

Example:

```heex
<button
  type="button"
  class="btn btn-error btn-sm"
  phx-click="delete-product-image"
  phx-value-id={@selected_product_image.id}
  data-confirm="Delete this product image?"
>
  Delete image
</button>
```

## Selected Image Requirement

The delete button should delete only the currently selected product image.

The selected image should come from LiveView assigns, for example:

```elixir
:selected_product_image
```

Do not allow deleting arbitrary product images by trusting only client params.

The server must verify that the selected image belongs to the current product.

## Ownership Safety Requirement

Only allow deleting product images that belong to the current product.

When handling delete:

```text
find image from current product's loaded product_images
```

Do not blindly delete any `ProductImage` by id.

Recommended helper:

```elixir
defp find_product_image(product, product_image_id) do
  Enum.find(product.product_images, fn product_image ->
    to_string(product_image.id) == to_string(product_image_id)
  end)
end
```

If the image id does not belong to the current product:

```text
do not delete anything
show error flash or ignore safely
do not crash
```

Recommended error flash:

```text
Product image not found.
```

## File Delete Requirement

When deleting a product image, delete both:

```text
original image file
thumbnail image file if it exists
```

Original image path:

```text
%{assets_path}/product_images/<filename>
```

Thumbnail image path:

```text
%{assets_path}/product_images/<thumbnail_filename>
```

The thumbnail filename is generated by appending:

```text
_500x500px
```

before the file extension.

Example:

```text
original:
12_550e8400-e29b-41d4-a716-446655440000.jpg

thumbnail:
12_550e8400-e29b-41d4-a716-446655440000_500x500px.jpg
```

## Thumbnail Filename Helper

Add or reuse a helper for thumbnail filename generation.

Recommended helper:

```elixir
def product_image_thumbnail_filename(filename) do
  ext = Path.extname(filename)
  root = Path.rootname(filename)

  "#{root}_500x500px#{ext}"
end
```

If this helper already exists from Task `039-13`, reuse it.

Do not duplicate inconsistent thumbnail filename logic.

## File Safety Requirement

Never delete files outside:

```text
%{assets_path}/product_images
```

The delete logic must reject unsafe filenames.

Reject filenames containing:

```text
../
/
\
```

The filename should be a basename only.

Recommended validation:

```elixir
Path.basename(filename) == filename
```

Only delete paths built from:

```elixir
Path.join([assets_path, "product_images", filename])
```

Do not accept raw file paths from client params.

## Delete Order Requirement

Recommended delete flow:

```text
validate product image belongs to current product
build original file path
build thumbnail file path
delete database ProductImage record
delete original file if exists
delete thumbnail file if exists
reload product with images
update selected image
show success flash
```

Alternative acceptable flow:

```text
delete files first
delete database record after files are removed
```

Either is acceptable, but error handling must be safe.

Preferred behavior:

```text
delete database record even if physical files are already missing
```

Reason:

```text
missing file should not block cleanup of stale ProductImage record
```

## Products Context Requirement

Update:

```text
lib/ca_heo_shop/products.ex
```

Add or reuse:

```elixir
delete_product_image(%ProductImage{} = product_image)
```

Expected behavior:

```text
hard deletes ProductImage record
returns {:ok, product_image} on success
returns {:error, changeset} on failure
```

Add a higher-level helper if useful:

```elixir
delete_product_image_with_files(%ProductImage{} = product_image)
```

Expected behavior:

```text
deletes original file if exists
deletes thumbnail file if exists
deletes ProductImage record
does not crash if files are missing
does not delete files outside product_images directory
```

Preferred direction:

```text
Keep database deletion in Products context.
Keep file path/delete helpers near upload/image storage logic.
```

Do not create a new context.

Keep using:

```text
CaHeoShop.Products
```

Do not create:

```text
CaHeoShop.ProductImages
```

## LiveView Event Requirement

Add event:

```text
delete-product-image
```

Expected payload:

```elixir
%{"id" => product_image_id}
```

Expected behavior:

```text
verify image belongs to current product
delete ProductImage record
delete original file
delete thumbnail file if exists
reload product with product_images
update selected image
show success flash
```

Recommended success flash:

```text
Product image deleted successfully.
```

Recommended failure flash:

```text
Could not delete product image.
```

## Selected Image After Delete

After deleting the selected image, update the selected image.

Recommended behavior:

```text
select image with lowest display_order
```

If no product images remain:

```text
selected_product_image = nil
show empty Image Preview state
show No product images in list
```

The page must not crash.

## Display Order After Delete

This task does not need to normalize remaining `display_order` values.

Example:

```text
before delete:
image A display_order = 0
image B display_order = 1
image C display_order = 2

delete image B

after delete:
image A display_order = 0
image C display_order = 2
```

This is acceptable.

Do not implement automatic reorder normalization in this task.

Image drag-drop ordering already belongs to Task `039-05`.

## Empty State Requirement

If the product has no images after delete:

```text
Product Images list shows No product images
Image Preview shows empty state
delete button is hidden or disabled
upload form remains visible
```

The admin should still be able to upload a new image.

## View Original Link Requirement

After deleting an image:

```text
View original link should not point to deleted file
```

If no image remains:

```text
hide View original link
```

If another image is selected:

```text
View original link points to the new selected image original filename
```

## Copy Filename Requirement

After deleting an image:

```text
Copy filename button should not copy deleted filename
```

If no image remains:

```text
hide or disable Copy filename button
```

If another image is selected:

```text
copy button copies new selected image filename
```

## Error Handling

Handle these cases safely:

```text
selected image id missing
selected image does not belong to current product
database delete failure
original file missing
thumbnail file missing
unsafe filename
file delete permission error
```

If original or thumbnail file is missing:

```text
do not crash
continue deleting ProductImage record
```

If file delete fails due to permission error:

```text
show error flash
do not crash
```

If database delete succeeds but file delete fails:

```text
log the file delete error clearly
show warning or error flash
```

Preferred behavior is to attempt file deletion before final success flash.

## Tests

Add or update tests.

## Products Context Tests

Test:

```text
delete_product_image/1 deletes ProductImage record
delete_product_image/1 does not delete Product
delete_product_image/1 does not delete other ProductImage records
```

If `delete_product_image_with_files/1` exists, test:

```text
delete_product_image_with_files/1 deletes database record
delete_product_image_with_files/1 deletes original image file
delete_product_image_with_files/1 deletes thumbnail image file if exists
delete_product_image_with_files/1 succeeds when original file is missing
delete_product_image_with_files/1 succeeds when thumbnail file is missing
delete_product_image_with_files/1 rejects unsafe filename
delete_product_image_with_files/1 does not delete outside product_images directory
```

If helper exists, test:

```text
product_image_thumbnail_filename/1 appends _500x500px before extension
```

Examples:

```text
12_uuid.jpg -> 12_uuid_500x500px.jpg
12_uuid.png -> 12_uuid_500x500px.png
12_uuid.jpeg -> 12_uuid_500x500px.jpeg
```

## LiveView Tests

Add tests for:

```text
/admin/products/:id
```

### Rendering Tests

Test:

```text
Image Preview renders Delete image button when image is selected
Image Preview hides or disables Delete image button when no image is selected
Delete image button has confirmation
```

### Delete Success Test

Test:

```text
admin selects product image
admin clicks Delete image
ProductImage record is deleted
original image file is deleted
thumbnail image file is deleted if exists
success flash is shown
deleted image disappears from Product Images list
Image Preview no longer shows deleted image
```

### Delete Image Without Thumbnail Test

Test:

```text
admin deletes product image with has_thumbnail = false
original image file is deleted
no thumbnail file is required
ProductImage record is deleted
page does not crash
```

### Delete Last Image Test

Test:

```text
admin deletes the last product image
Product Images list shows No product images
Image Preview shows empty state
View original link is hidden
Copy filename button is hidden or disabled
Delete image button is hidden or disabled
upload form remains visible
```

### Selected Image After Delete Test

Test:

```text
admin deletes selected image
another image is selected automatically if available
Image Preview shows the new selected image
View original link points to the new selected image
Copy filename button copies the new selected filename
```

### Ownership Safety Test

Test:

```text
attempting to delete image from another product is rejected or ignored
image from another product is not deleted
file from another product is not deleted
```

### Unsafe Filename Test

Test:

```text
product image with unsafe filename is not used to delete outside product_images directory
unsafe filename delete shows error or is rejected safely
```

### Existing Page Behavior Test

Verify existing sections still work:

```text
Product Summary still renders
Product content still renders
Product variants table still renders if implemented
Product Images upload form still renders
Product Images drag-drop still works if implemented
```

## Manual Verification

Manually verify:

```text
upload product image
wait until thumbnail is generated
open /admin/products/:id
select uploaded image
click Delete image
confirm delete
original file is removed from %{assets_path}/product_images
thumbnail file is removed from %{assets_path}/product_images
ProductImage row is removed from database
Product Images list updates
Image Preview updates
upload form still works
```

## Authorization Tests

If earlier tasks already cover product detail authorization, do not duplicate too much.

At minimum, verify:

```text
admin can delete product image
customer cannot access /admin/products/:id
system cannot access /admin/products/:id
anonymous user redirects to login
```

## Acceptance Criteria

The task is complete when:

```text
mix test passes
/admin/products/:id still works
Image Preview has Delete image button for selected image
Delete image button asks for confirmation
admin can delete selected product image
ProductImage database record is hard deleted
original product image file is deleted
thumbnail product image file is deleted if it exists
missing original file does not crash delete flow
missing thumbnail file does not crash delete flow
unsafe filenames cannot delete files outside %{assets_path}/product_images
deleted image disappears from Product Images list
Image Preview no longer shows deleted image
View original link does not point to deleted file
Copy filename button does not copy deleted filename
after delete another image is selected if available
after deleting last image, empty state is shown
upload form remains visible after delete
no soft delete field is added
no image archive behavior is implemented
no bulk delete behavior is implemented
no thumbnail generation behavior is implemented
```

## Notes

Keep this task focused on deleting one selected product image from the `Image Preview` section.

Deleting image means deleting all related physical files:

```text
original image file
500x500px thumbnail file
```

Future tasks can add:

```text
bulk image delete
image replacement
manual thumbnail regenerate
image metadata editing
display_order normalization after delete
```
